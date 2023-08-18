//
//  TwocheckoutFlutterPlugin.kt
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
package com.twocheckout.twocheckout_flutter

import android.app.Activity
import android.app.AlertDialog
import android.app.ProgressDialog
import android.content.Context
import android.content.Intent
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import androidx.core.content.ContextCompat.startActivity
import androidx.core.content.res.ResourcesCompat
import com.twocheckout.twocheckout_flutter.datapack.FormUICustomizationData
import com.twocheckout.twocheckout_flutter.datapack.PaymentConfigurationData
import com.twocheckout.twocheckout_flutter.http.CheckOrderStatus
import com.twocheckout.twocheckout_flutter.http.HttpAuthenticationAPI
import com.twocheckout.twocheckout_flutter.http.OrdersCardPaymentAPI
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsAuthForm
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsManager
import com.twocheckout.twocheckout_flutter.payments.paypal.PaypalStarter
import com.twocheckout.twocheckout_flutter.screens.TwoCheckoutPaymentForm
import com.twocheckout.twocheckout_flutter.screens.TwoCheckoutPaymentOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONObject
import java.util.*


/** TwocheckoutFlutterPlugin */
class TwocheckoutFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity
  @Volatile private lateinit var progressDialog: ProgressDialog
  private var transactionRefNo =""
  //private val threedsReceiver = createPaymentsReceiver()
  private val itemPrice = 0.01
  companion object{
    const val keyMerchantSecret = "merchant_secret_key"
    const val keyMerchantCode = "merchant_code"
    const val keyCardPaymentsUrl="card_payments_url"
    var currencyTV = "EUR"
   // private val paypalReceiver = createPaypalReceiver()

    fun getCardPaymentsUrl(ctx:Context):String {
      val sharedPref = ctx.getSharedPreferences("payment_settings_data", Context.MODE_PRIVATE)
      return sharedPref.getString(keyCardPaymentsUrl,"")?:""
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "twocheckout_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    progressDialog = ProgressDialog(context)


  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when (call.method) {
        "showPaymentMethods" -> {
         // showPaymentOptions(context)
          showNativeAlert("sdfsd","sdfsdf")
        }
        "setTwoCheckCredentials" -> {
          val arguments: Map<String, Any>? = call.arguments()
          val arg1 = arguments?.get("arg1") as String
          val arg2 = arguments["arg2"] as String
          Setting.secretKey = arg1
          Setting.merchantCode = arg2
        }
        else -> {
          result.notImplemented()
        }
    }
  }
  private fun showNativeAlert(title: String, msg: String) {
    val arguments = hashMapOf<String, String>()
    arguments["title"] = title
    arguments["message"] = msg
    channel.invokeMethod("showFlutterAlert", arguments)
  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
      activity = binding.activity;
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

/*  fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    if (requestCode == 123) { // Make sure to match the request code
      if (resultCode == Activity.RESULT_OK) {
        val refNO = data?.getStringExtra(ThreedsManager.keyRefNO)?:""
        if (refNO.isNotEmpty()){
            launchOrderStatusCheck(refNO)
        } else {
          Toast.makeText(context," Card transaction failed",Toast.LENGTH_LONG).show()
        }
      }
    }
  }*/
  private fun showPaymentOptions( context: Context) {
    val payOptionsList = ArrayList<String>(2)
    payOptionsList.add(TwoCheckoutPaymentOptions.paymentOptionCard)
    payOptionsList.add(TwoCheckoutPaymentOptions.paymentOptionPayPal)

    if (payOptionsList.isEmpty()) {
        Toast.makeText(context," Emtpy list",Toast.LENGTH_LONG).show()
      return
    }

    val paymentOptionsSheet = TwoCheckoutPaymentOptions(activity,payOptionsList,::onPayMethodSelected)
    paymentOptionsSheet.showPaymentOptionList()
  }

  private fun onPayMethodSelected(payMethod:String) {
    if (payMethod == TwoCheckoutPaymentOptions.paymentOptionPayPal) {
    //  showLoadingSpinner()
      channel.invokeMethod("showLoading", HashMap<String, Any>())
      startPaypalFlow()
      //    Toast.makeText(context,"Paypal selected",Toast.LENGTH_LONG).show()
    } else if (payMethod == TwoCheckoutPaymentOptions.paymentOptionCard) {
          Toast.makeText(context,"Card selected",Toast.LENGTH_LONG).show()
      gotoCardFormPayment(Setting.merchantCode)
    }
  }


  private fun gotoCardFormPayment(merchantCode:String) {
    val customizationParam = loadFormPreferences()
    customizationParam.userTextFont = parseFont()
    customizationParam.userTextFontRes =  R.font.oswald_demibold
    val fullPrice = "$0.01 EUR"
   // setLocation(false)
    val formConfigData = PaymentConfigurationData(
      activity,
      fullPrice,
      merchantCode,
      customizationParam
    )


    val cardPaymentForm = TwoCheckoutPaymentForm(
      formConfigData,::showLoadingSpinner,
      ::onCreditCardInput
    )
    val settingsUrlParam  = getCardPaymentsUrl(context)
    if (settingsUrlParam.isNotEmpty()){
      cardPaymentForm.overrideTokenURL(settingsUrlParam)
    }
    cardPaymentForm.displayPaymentForm()
  }


  private fun loadFormPreferences():FormUICustomizationData {
   // val sharedPref = getSharedPreferences("customization", Context.MODE_PRIVATE)
    val temp = FormUICustomizationData()
    temp.paymentFormBackground = "white"
    temp.formTextFieldsBackground = "white"
    temp.formInputTextColor =  "black"
    temp.hintTextColor = "black"//sharedPref.getString(keySaveHintColor, "")?:""
    temp.payButtonColor = "grey"// sharedPref.getString(keySavePayBtnColor, "")?:""
    temp.formTitleTextColor = "orange"//sharedPref.getString(keySaveTitleColor, "")?:""
    return temp
  }

  private fun parseFont():Typeface? {
    return  ResourcesCompat.getFont(context, R.font.oswald_demibold)

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
   /* Handler(Looper.getMainLooper()).post(Runnable {
      progressDialog.setTitle("Processing transaction...")
      progressDialog.setCancelable(true)
      progressDialog.show()})*/

  }

  private fun onCreditCardInput(cardPaymentToken:String) {
    if (cardPaymentToken.isEmpty()){
      progressDialog.dismiss()
      showNativeAlert("Get token failed","Card transaction failed,")
     // ErrorDisplayDialog.ErrorDisplayDialog.newInstance("Card transaction failed","Get token failed").show(supportFragmentManager,"error")
      return
    }
    val ordersCardPayment = OrdersCardPaymentAPI(currencyTV,false,::onCardPaymentComplete)
    val httpAuthAPI = HttpAuthenticationAPI()
    httpAuthAPI.secretKey = Setting.secretKey
    httpAuthAPI.merchantCode = Setting.merchantCode
    try {
      val headersTemp = httpAuthAPI.getHeaders()
      ordersCardPayment.overridePaymentURL(getCardPaymentsUrl(context))
      ordersCardPayment.authHeaders = headersTemp
      ordersCardPayment.launchAPI(cardPaymentToken)
    } catch (e:Exception) {
      e.printStackTrace()
    }
  }

  private fun onCardPaymentComplete(result: String) {
    progressDialog.dismiss()
    if (result.isEmpty()) {
      showNativeAlert("Card payment","Card transaction failed")
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
      showNativeAlert("Card Transaction","Card transaction failed")
      return
    }
    if (transactionStatus == "AUTHRECEIVED") {
         gotoPaymentDoneScreen(reference,PaymentFlowDone.TransactionType.typeCreditCard.name,""+itemPrice,"John Doe",
           currencyTV)
    } else {
      Toast.makeText(context, " Card transaction status", Toast.LENGTH_LONG).show()
      showNativeAlert("Card transaction status",transactionStatus)
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
    } catch (e:Exception) {
      e.printStackTrace()
    }
    if (token.isEmpty()) return ""
    return responseJson.getJSONObject("PaymentDetails").getJSONObject("PaymentMethod")
      .getJSONObject("Authorize3DS").getString("Href") + "?avng8apitoken=$token"
  }

  private fun startThreedsAuth(threedsUrl:String) {
    if(threedsUrl.isEmpty()){
      progressDialog.dismiss()
    }
    val temp = Intent(context, ThreedsAuthForm::class.java)
    temp.putExtra(ThreedsManager.keyThreedsURL,threedsUrl)
    activity.startActivityForResult(temp,ThreedsManager.threedsResultCode)
  }

 /* private fun createPaymentsReceiver(): ActivityResultLauncher<Intent> {
    val actResLauncher: ActivityResultLauncher<Intent> =
      registerForActivityResult(ActivityResultContracts.StartActivityForResult()){
          result: ActivityResult ->
        if (result.resultCode == ThreedsManager.threedsResultCode) {
          if (result.data!=null) {
            result.data?.let {
              val refNO = it.getStringExtra(ThreedsManager.keyRefNO)?:""
              if (refNO.isNotEmpty()){
              //  launchOrderStatusCheck(refNO)
              } else {
                Toast.makeText(context," Card transaction failed",Toast.LENGTH_LONG).show()

               // ErrorDisplayDialog.newInstance("Card transaction failed","unknown error").show(supportFragmentManager,"error")
              }
            }
          }
        }
      }
    return actResLauncher
  }*/

 /* private fun saveRefNO(){
    val sharedPref = getSharedPreferences("main_screen", Context.MODE_PRIVATE)
    sharedPref.edit().putString("key_transaction_ref",transactionRefNo).apply()
  }*/

  private fun startPaypalFlow(){
    val ordersPaypalPayment = OrdersCardPaymentAPI(currencyTV,true,::onPaypalFlowComplete)
    val httpAuthAPI = HttpAuthenticationAPI()
    httpAuthAPI.secretKey = Setting.secretKey
    httpAuthAPI.merchantCode = Setting.merchantCode
    try {
      val headersTemp = httpAuthAPI.getHeaders()
      ordersPaypalPayment.authHeaders = headersTemp
      ordersPaypalPayment.launchAPI("")
    } catch (e:Exception) {
      progressDialog.dismiss()
      Toast.makeText(context,"Paypal error",Toast.LENGTH_LONG).show()
      showNativeAlert("Paypal error","Invalid key")
      e.printStackTrace()
    }
  }

  private fun onPaypalFlowComplete(result:String){
    progressDialog.dismiss()
    if(result.isEmpty()){
      showNativeAlert("Card transaction failed","unknown error")
      return
    }
    val redirectURL = getPaypalUrl(result)

    if (redirectURL.isNotEmpty()){
      startPaypalScreen(redirectURL)
      return
    }
    var transactionStatus = ""
    var reference =""
    try{
      val resultJson = JSONObject(result)
      transactionStatus = resultJson.getString("Status")
      reference = resultJson.getString("RefNo")}
    catch (e:java.lang.Exception) {
      showNativeAlert("Card transaction failed","unknown error")

      return
    }
    if (transactionStatus=="AUTHRECEIVED"){
        gotoPaymentDoneScreen(reference,PaymentFlowDone.TransactionType.typeCreditCard.name,""+itemPrice,"John Doe",
          currencyTV)
    } else {
      Log.d("PaypalFlow ", "Card transaction status")
    }
    transactionRefNo = ""
    Log.d("PaypalFlow ", "saveRefNO")
    showNativeAlert("Card transaction status",transactionStatus)

  }

  private fun getPaypalUrl(response: String): String {
    val responseJson = JSONObject(response)
    try {
      transactionRefNo = responseJson.getString("RefNo")
      return responseJson.getJSONObject("PaymentDetails").getJSONObject("PaymentMethod")
        .getString("RedirectURL")

    } catch (e:Exception) {
      e.printStackTrace()
      return ""
    }
  }

  private fun startPaypalScreen(paypalUrl:String){
    if(paypalUrl.isEmpty()){
      progressDialog.dismiss()
    }
    val mPaypalStarter = PaypalStarter(context,paypalUrl)
   // mPaypalStarter.displayPaypalScreen(paypalReceiver)
  }

 /* private fun createPaypalReceiver(): ActivityResultLauncher<Intent> {
    val actResLauncher: ActivityResultLauncher<Intent> =
      registerForActivityResult(ActivityResultContracts.StartActivityForResult()){
          result: ActivityResult ->

        if (result.resultCode == PaypalStarter.paypalResultCode) {
          if (result.data!=null) {
            result.data?.let {
              val refNO = it.getStringExtra(PaypalStarter.keyRefNO)?:""
              if (refNO.isNotEmpty()){
                launchOrderStatusCheck(refNO)
              } else {
                Toast.makeText(context,"Card transaction failed,unknown error",Toast.LENGTH_LONG).show()

            //    ErrorDisplayDialog.newInstance("Card transaction failed","unknown error").show(supportFragmentManager,"error")
              }
            }
          }
        }
      }
    return actResLauncher
  }*/


  private fun launchOrderStatusCheck(authRefParam:String){
    val checkOrderStatus = CheckOrderStatus(::onOrderCheckStatus)
    val httpAuthAPI = HttpAuthenticationAPI()
    httpAuthAPI.secretKey = Setting.secretKey
    httpAuthAPI.merchantCode = Setting.merchantCode
    try {
      val headersTemp = httpAuthAPI.getHeaders()
      checkOrderStatus.authHeaders = headersTemp
      checkOrderStatus.launchAPI(authRefParam)
    } catch (e:Exception) {
      e.printStackTrace()
    }
  }

  private fun onOrderCheckStatus(result:String){
    progressDialog.dismiss()
    try {
      val statusObj = JSONObject(result)
      val statusResult = statusObj.getString("Status")
      if (statusResult == "AUTHRECEIVED"){
        val referenceNO = statusObj.getString("RefNo")
        gotoPaymentDoneScreen(referenceNO,PaymentFlowDone.TransactionType.typeCreditCard.name,""+itemPrice,"John Doe",
          currencyTV)

        Toast.makeText(context,"gotoPaymentDoneScreen",Toast.LENGTH_LONG).show()

      } else {
        showNativeAlert("Card transaction failed","unknown error")
      }
    } catch (e:Exception){
      e.printStackTrace()
      showNativeAlert("Card transaction failed","unknown error")
    }
    transactionRefNo = ""
  }
  private fun gotoPaymentDoneScreen(reference: String,transactionType:String ,amount: String,customerParam:String,currencyParam:String) {
    val paymentDone = Intent(context, PaymentFlowDone::class.java)
    paymentDone.putExtra(PaymentFlowDone.keyPayerName, customerParam)
    paymentDone.putExtra(PaymentFlowDone.keyTransactionReference, reference)
    paymentDone.putExtra(PaymentFlowDone.keyTransactionAmount, amount)
    paymentDone.putExtra(PaymentFlowDone.keyTransactionCurrency,currencyParam)
    paymentDone.putExtra(PaymentFlowDone.keyTransactionType,transactionType)
    activity.startActivity(paymentDone)
  }
}
