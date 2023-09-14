//
//  TwocheckoutFlutterPlugin.kt
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
package com.twocheckout.twocheckout_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Typeface
import android.util.Log
import android.widget.Toast
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.NonNull
import androidx.core.content.res.ResourcesCompat
import com.twocheckout.twocheckout_flutter.datapack.FormUICustomizationData
import com.twocheckout.twocheckout_flutter.datapack.PaymentConfigurationData
import com.twocheckout.twocheckout_flutter.http.CheckOrderStatus
import com.twocheckout.twocheckout_flutter.http.HttpAuthenticationAPI
import com.twocheckout.twocheckout_flutter.http.OrdersCardPaymentAPI
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsAuthForm
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsManager
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsManager.Companion.threedsResultCode
import com.twocheckout.twocheckout_flutter.payments.paypal.PaypalStarter
import com.twocheckout.twocheckout_flutter.payments.paypal.PaypalStarter.Companion.paypalResultCode
import com.twocheckout.twocheckout_flutter.payments.paypal.PaypalWebScreen
import com.twocheckout.twocheckout_flutter.screens.TwoCheckoutPaymentForm
import com.twocheckout.twocheckout_flutter.screens.TwoCheckoutPaymentOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import org.json.JSONObject
import java.util.*


/** TwocheckoutFlutterPlugin */
class TwocheckoutFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private var transactionRefNo = ""
    private val itemPrice = 0.01

    companion object {
        const val keyMerchantSecret = "merchant_secret_key"
        const val keyMerchantCode = "merchant_code"
        const val keyCardPaymentsUrl = "card_payments_url"
        var currencyTV = "EUR"
        fun getCardPaymentsUrl(ctx: Context): String {
            val sharedPref = ctx.getSharedPreferences("payment_settings_data", Context.MODE_PRIVATE)
            return sharedPref.getString(keyCardPaymentsUrl, "") ?: ""
        }

        //credentials for 2checkout

        var secretKey = ""
        var merchantCode = ""

        // Method-channel functions

        const val SHOW_LOADING_SPINNER = "showLoadingSpinner"
        const val ALERT_DIALOG = "showFlutterAlert"
        const val DISMISS_LOADING_SPINNNER = "dismissProgressbar"
        const val SHOW_PAYMENT_METHODS = "showPaymentMethods"
        const val SET_2CHECKOUT_CREDENTIALS = "setTwoCheckCredentials"
        const val PAYMENT_FLOW_DONE = "PaymentFlowDone"
        const val API_RESPONSE = "apiResponse"

    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "twocheckout_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext


    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            SHOW_PAYMENT_METHODS -> {
               // gotoPaymentDoneScreen("", "", "", "", "")
                 showPaymentOptions(context)
            }
            SET_2CHECKOUT_CREDENTIALS -> {
                val arguments: Map<String, Any>? = call.arguments()
                val arg1 = arguments?.get("arg1") as String
                val arg2 = arguments["arg2"] as String
                secretKey = arg1
                merchantCode = arg2
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == threedsResultCode || requestCode == paypalResultCode) { // Make sure to match the request code
            val refNO = data?.getStringExtra(ThreedsManager.keyRefNO) ?: ""
            if (refNO.isNotEmpty()) {
                launchOrderStatusCheck(refNO)
            } else {
                Toast.makeText(context, " Card transaction failed", Toast.LENGTH_LONG).show()
            }
        }
        return false
    }
    private fun showNativeAlert(title: String, msg: String) {
        val arguments = hashMapOf<String, String>()
        arguments["title"] = title
        arguments["message"] = msg
        channel.invokeMethod(ALERT_DIALOG, arguments)
    }

    private fun onApiCallResponse(response: String) {
        channel.invokeMethod(API_RESPONSE, response)
    }

    private fun onPaypalFailureResponse(title: String, msg: String) {
        val arguments = hashMapOf<String, String>()
        arguments["title"] = title
        arguments["message"] = msg
        channel.invokeMethod(ALERT_DIALOG, arguments)
    }
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this);
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }

    private fun showPaymentOptions(context: Context) {
        val payOptionsList = ArrayList<String>(2)
        payOptionsList.add(TwoCheckoutPaymentOptions.paymentOptionCard)
        payOptionsList.add(TwoCheckoutPaymentOptions.paymentOptionPayPal)

        if (payOptionsList.isEmpty()) {
            Toast.makeText(context, " Emtpy list", Toast.LENGTH_LONG).show()
            return
        }

        val paymentOptionsSheet =
            TwoCheckoutPaymentOptions(activity , payOptionsList, ::onPayMethodSelected)
        paymentOptionsSheet.showPaymentOptionList()
    }

    private fun onPayMethodSelected(payMethod: String) {
        if (payMethod == TwoCheckoutPaymentOptions.paymentOptionPayPal) {
            showLoadingSpinner()
            startPaypalFlow()
        } else if (payMethod == TwoCheckoutPaymentOptions.paymentOptionCard) {
            //  channel.invokeMethod(SHOW_LOADING_SPINNER,null)
            gotoCardFormPayment(merchantCode)
            //startThreedsAuth("https://www.example.com/?avng8apitoken=your_token_value_here")
        }
    }


    private fun gotoCardFormPayment(merchantCode: String) {
        val customizationParam = loadFormPreferences()
        customizationParam.userTextFont = parseFont()
        customizationParam.userTextFontRes = R.font.oswald_demibold
        val fullPrice = "$0.01 EUR"
        // setLocation(false)
        val formConfigData = PaymentConfigurationData(
            activity,
            fullPrice,
            merchantCode,
            customizationParam
        )


        val cardPaymentForm = TwoCheckoutPaymentForm(
            formConfigData, ::showLoadingSpinner,
            ::onCreditCardInput
        )
        val settingsUrlParam = getCardPaymentsUrl(context)
        if (settingsUrlParam.isNotEmpty()) {
            cardPaymentForm.overrideTokenURL(settingsUrlParam)
        }
        cardPaymentForm.displayPaymentForm()
    }


    private fun loadFormPreferences(): FormUICustomizationData {
        // val sharedPref = getSharedPreferences("customization", Context.MODE_PRIVATE)
        val temp = FormUICustomizationData()
        temp.paymentFormBackground = "white"
        temp.formTextFieldsBackground = "white"
        temp.formInputTextColor = "black"
        temp.hintTextColor = "black"//sharedPref.getString(keySaveHintColor, "")?:""
        temp.payButtonColor = "grey"// sharedPref.getString(keySavePayBtnColor, "")?:""
        temp.formTitleTextColor = "orange"//sharedPref.getString(keySaveTitleColor, "")?:""
        return temp
    }

    private fun parseFont(): Typeface? {
        return ResourcesCompat.getFont(context, R.font.oswald_demibold)

    }


    /*private fun setLocation(setEnglish:Boolean) {
      var langSelected = "EN"
      if (!setEnglish){
        try{
          langSelected = getStoredLanguage(context).substring(0,2)
        }catch (e:StringIndexOutOfBoundsException){
          langSelected = "EN"
        }
      }

      val locale = Locale(langSelected)
      Locale.setDefault(locale)
      val config = Configuration()
      config.locale = locale
      activity.resources.updateConfiguration(config, this.resources.displayMetrics)
    }
  */
    private fun showLoadingSpinner() {
        channel.invokeMethod(SHOW_LOADING_SPINNER, null)
    }

    private fun dismissLoadingSpinner() {
        channel.invokeMethod(DISMISS_LOADING_SPINNNER, null)
    }

    private fun onCreditCardInput(cardPaymentToken: String) {
        if (cardPaymentToken.isEmpty()) {
            dismissLoadingSpinner()
            showNativeAlert("Get token failed", "Card transaction failed,")
            return
        }
        val ordersCardPayment = OrdersCardPaymentAPI(currencyTV, false, ::onCardPaymentComplete)
        val httpAuthAPI = HttpAuthenticationAPI()
        httpAuthAPI.secretKey = secretKey
        httpAuthAPI.merchantCode = merchantCode
        try {
            val headersTemp = httpAuthAPI.getHeaders()
            ordersCardPayment.overridePaymentURL(getCardPaymentsUrl(context))
            ordersCardPayment.authHeaders = headersTemp
            ordersCardPayment.launchAPI(cardPaymentToken)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    // sample function for retrieving 2CO card order payment result
    private fun onCardPaymentComplete(result: String) {
        dismissLoadingSpinner()
        if (result.isEmpty()) {
            showNativeAlert("Card payment", "Card transaction failed")
            return
        }
        val threedsResult = getThreedsUrl(result)

        if (threedsResult.isNotEmpty()) {
            startThreedsAuth(threedsResult)
            return
        }
        var transactionStatus = ""
        var reference = ""
        try {
            val resultJson = JSONObject(result)
            transactionStatus = resultJson.getString("Status")
            reference = resultJson.getString("RefNo")
        } catch (e: java.lang.Exception) {
            showNativeAlert("Card Transaction", "Card transaction failed")
            return
        }
        if (transactionStatus == "AUTHRECEIVED") {
            gotoPaymentDoneScreen(
                reference,
                PaymentFlowDone.TransactionType.typeCreditCard.name,
                "" + itemPrice,
                "John Doe",
                currencyTV
            )
        } else {
            Toast.makeText(context, " Card transaction status", Toast.LENGTH_LONG).show()
            showNativeAlert("Card transaction status", transactionStatus)
        }
        transactionRefNo = ""
        //saveRefNO()
        Toast.makeText(context, " saveRefNO", Toast.LENGTH_LONG).show()

    }

    private fun getThreedsUrl(response: String): String {
        val responseJson = JSONObject(response)
        var token = ""
        try {
            token = responseJson.getJSONObject("PaymentDetails").getJSONObject("PaymentMethod")
                .getJSONObject("Authorize3DS").getJSONObject("Params").getString("avng8apitoken")
            transactionRefNo = responseJson.getString("RefNo")
        } catch (e: Exception) {
            e.printStackTrace()
        }
        if (token.isEmpty()) return ""
        return responseJson.getJSONObject("PaymentDetails").getJSONObject("PaymentMethod")
            .getJSONObject("Authorize3DS").getString("Href") + "?avng8apitoken=$token"
    }

    private fun startThreedsAuth(threedsUrl: String) {
        if (threedsUrl.isEmpty()) {
            dismissLoadingSpinner()
        }
        val temp = Intent(context, ThreedsAuthForm::class.java)
        temp.putExtra(ThreedsManager.keyThreedsURL, threedsUrl)
        activity.startActivityForResult(temp, threedsResultCode)
    }

    /* private fun saveRefNO(){
       val sharedPref = getSharedPreferences("main_screen", Context.MODE_PRIVATE)
       sharedPref.edit().putString("key_transaction_ref",transactionRefNo).apply()
     }*/

    private fun startPaypalFlow() {
        val ordersPaypalPayment = OrdersCardPaymentAPI(currencyTV, true, ::onPaypalFlowComplete)
        val httpAuthAPI = HttpAuthenticationAPI()
        httpAuthAPI.secretKey = secretKey
        httpAuthAPI.merchantCode = merchantCode
        try {
            val headersTemp = httpAuthAPI.getHeaders()
            ordersPaypalPayment.authHeaders = headersTemp
            ordersPaypalPayment.launchAPI("")

        } catch (e: Exception) {

            Toast.makeText(context, "Paypal error", Toast.LENGTH_LONG).show()
            showNativeAlert("Paypal error", "Invalid key")
            e.printStackTrace()
        }
        dismissLoadingSpinner()
    }

    private fun onPaypalFlowComplete(result: String) {
        dismissLoadingSpinner()
        if (result.isEmpty()) {
            showNativeAlert("Card transaction failed", "unknown error")
            return
        }
        val redirectURL = getPaypalUrl(result)
        if (redirectURL.isNotEmpty()) {
            startPaypalScreen(redirectURL)
            return
        }
        var transactionStatus = ""
        var reference = ""
        try {
            val resultJson = JSONObject(result)
            transactionStatus = resultJson.getString("Status")
            reference = resultJson.getString("RefNo")
        } catch (e: java.lang.Exception) {
            showNativeAlert("Card transaction failed", "unknown error")

            return
        }
        if (transactionStatus == "AUTHRECEIVED") {
            gotoPaymentDoneScreen(
                reference,
                PaymentFlowDone.TransactionType.typeCreditCard.name,
                "" + itemPrice,
                "John Doe",
                currencyTV
            )
        } else {
            Log.d("PaypalFlow ", "Card transaction status")
        }
        transactionRefNo = ""
        Log.d("PaypalFlow ", "saveRefNO")
        showNativeAlert("Card transaction status", transactionStatus)

    }

    private fun getPaypalUrl(response: String): String {
        val responseJson = JSONObject(response)
        try {
            transactionRefNo = responseJson.getString("RefNo")
            return responseJson.getJSONObject("PaymentDetails").getJSONObject("PaymentMethod")
                .getString("RedirectURL")

        } catch (e: Exception) {
            e.printStackTrace()
            return ""
        }
    }

    private fun startPaypalScreen(paypalUrl: String) {
        if (paypalUrl.isEmpty()) {
            dismissLoadingSpinner()
        }

        val temp = Intent(context, PaypalWebScreen::class.java)
        temp.putExtra(PaypalStarter.keyPaypalURL, paypalUrl)
        activity.startActivityForResult(temp, paypalResultCode)

    }

    private fun launchOrderStatusCheck(authRefParam: String) {
        val checkOrderStatus = CheckOrderStatus(::onOrderCheckStatus)
        val httpAuthAPI = HttpAuthenticationAPI()
        httpAuthAPI.secretKey = secretKey
        httpAuthAPI.merchantCode = merchantCode
        try {
            val headersTemp = httpAuthAPI.getHeaders()
            checkOrderStatus.authHeaders = headersTemp
            checkOrderStatus.launchAPI(authRefParam)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun onOrderCheckStatus(result: String) {
        dismissLoadingSpinner()
        try {
            val statusObj = JSONObject(result)
            val statusResult = statusObj.getString("Status")
            if (statusResult == "AUTHRECEIVED") {
                val referenceNO = statusObj.getString("RefNo")
                gotoPaymentDoneScreen(
                    referenceNO,
                    PaymentFlowDone.TransactionType.typeCreditCard.name,
                    "" + itemPrice,
                    "John Doe",
                    currencyTV
                )
            } else {
                showNativeAlert("Card transaction failed", "unknown error")
            }
        } catch (e: Exception) {
            e.printStackTrace()
            showNativeAlert("Card transaction failed", "unknown error")
        }
        transactionRefNo = ""
    }

    private fun gotoPaymentDoneScreen(
        reference: String,
        transactionType: String,
        amount: String,
        customerParam: String,
        currencyParam: String
    ) {
        val arguments = hashMapOf<String, String>()
        arguments["reference"] = reference
        arguments["amount"] = amount
        arguments["customerParam"] = customerParam
        arguments["currencyParam"] = currencyParam
        arguments["transactionType"] = transactionType
        channel.invokeMethod(PAYMENT_FLOW_DONE, arguments)
    }
}
