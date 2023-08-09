package com.twocheckout.twocheckout_flutter

import android.app.Activity
import android.app.ProgressDialog
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Typeface
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.annotation.NonNull
import androidx.core.content.res.ResourcesCompat
import androidx.appcompat.app.AppCompatActivity
import com.twocheckout.twocheckout_flutter.datapack.FormUICustomizationData
import com.twocheckout.twocheckout_flutter.datapack.PaymentConfigurationData
import com.twocheckout.twocheckout_flutter.http.HttpAuthenticationAPI
import com.twocheckout.twocheckout_flutter.http.OrdersCardPaymentAPI
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsManager
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
class TwocheckoutFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware{
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
  companion object{
    const val keyMerchantSecret = "merchant_secret_key"
    const val keyMerchantCode = "merchant_code"
    const val keySaveBackgroundColor="pref_background_color"
    const val keySaveInputTextColor="pref_input_text_color"
    const val keySaveTextFieldsColor="pref_text_fields_color"
    const val keySaveHintColor="pref_hint_color"
    const val keySavePayBtnColor="pref_pay_btn_color"
    const val keySaveTitleColor="pref_title_color"
    const val keyCardPaymentsUrl="card_payments_url"
    var currencyTV = "EUR"
    fun saveShowCard(ctx:Context,showCard:Boolean) {
      val sp = ctx.getSharedPreferences("checkout_data", Context.MODE_PRIVATE)
      sp.edit().putBoolean("key_store_show_card",showCard).apply()
    }

    fun getShowCard(ctx:Context):Boolean {
      val sharedPref = ctx.getSharedPreferences("checkout_data", Context.MODE_PRIVATE)
      return sharedPref.getBoolean("key_store_show_card",false)
    }

    fun saveShowPaypal(ctx:Context,showPaypal:Boolean) {
      val sp = ctx.getSharedPreferences("checkout_data", Context.MODE_PRIVATE)
      sp.edit().putBoolean("key_store_show_paypal",showPaypal).apply()
    }

    fun getShowPaypal(ctx:Context):Boolean {
      val sharedPref = ctx.getSharedPreferences("checkout_data", Context.MODE_PRIVATE)
      return sharedPref.getBoolean("key_store_show_paypal",false)
    }
    fun getCardPaymentsUrl(ctx:Context):String {
      val sharedPref = ctx.getSharedPreferences("payment_settings_data", Context.MODE_PRIVATE)
      return sharedPref.getString(keyCardPaymentsUrl,"")?:""
    }

    fun getMerchantSecretKey(ctx:Context):String {
      val sharedPref = ctx.getSharedPreferences("payment_settings_data", Context.MODE_PRIVATE)
      return sharedPref.getString(keyMerchantSecret,"")?:""
    }

    fun getMerchantCode(ctx:Context):String {
      val sharedPref = ctx.getSharedPreferences("payment_settings_data", Context.MODE_PRIVATE)
      return sharedPref.getString(keyMerchantCode,"")?:""
    }
    fun getStoredFont(ctx:Context):String {
      val sharedPref = ctx.getSharedPreferences("checkout_data", Context.MODE_PRIVATE)
      return sharedPref.getString("key_store_font","")?:""
    }
    fun getStoredLanguage(ctx:Context):String {
      val sharedPref = ctx.getSharedPreferences("checkout_data", Context.MODE_PRIVATE)
      return sharedPref.getString("key_store_lang","")?:""
    }

  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "twocheckout_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    progressDialog = ProgressDialog(context)


  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    if (call.method == "showPaymentMethods") {
      showPaymentOptions(context)
    } else {
      result.notImplemented()
    }
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
      // startPaypalFlow()
      //    Toast.makeText(context,"Paypal selected",Toast.LENGTH_LONG).show()
    } else if (payMethod == TwoCheckoutPaymentOptions.paymentOptionCard) {
          Toast.makeText(context,"Card selected",Toast.LENGTH_LONG).show()
      gotoCardFormPayment(getMerchantCode(context))
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
    /*activity.runOnUiThread {
      progressDialog.setTitle("Processing transaction...")
      progressDialog.setCancelable(true)
      progressDialog.show()
    }*/
  }

  private fun onCreditCardInput(cardPaymentToken:String) {
    if (cardPaymentToken.isEmpty()){
      progressDialog.dismiss()
      Toast.makeText(context," Get token failed",Toast.LENGTH_LONG).show()

     // ErrorDisplayDialog.ErrorDisplayDialog.newInstance("Card transaction failed","Get token failed").show(supportFragmentManager,"error")
      return
    }
    val ordersCardPayment = OrdersCardPaymentAPI(currencyTV,false,::onCardPaymentComplete)
    val httpAuthAPI = HttpAuthenticationAPI()
    httpAuthAPI.secretKey = "254558257678"//getMerchantSecretKey(this)
    httpAuthAPI.merchantCode = "GksS#rw&n_X^gv3xLBNU"//getMerchantCode(this)
    try {
      val headersTemp = httpAuthAPI.getHeaders()
      ordersCardPayment.overridePaymentURL(getCardPaymentsUrl(context))
      ordersCardPayment.authHeaders = headersTemp
      ordersCardPayment.launchAPI(cardPaymentToken)
    } catch (e:Exception) {
      e.printStackTrace()
    }
  }

  private fun onCardPaymentComplete(result:String) {
    progressDialog.dismiss()
    if(result.isEmpty()){
      Toast.makeText(context," Card transaction failed",Toast.LENGTH_LONG).show()

     // ErrorDisplayDialog.newInstance("Card transaction failed","unknown error").show(supportFragmentManager,"error")
      return
    }
    val threedsResult = getThreedsUrl(result)

    if (threedsResult.isNotEmpty()){
      startThreedsAuth(threedsResult)
      return
    }
    var transactionStatus = ""
    var reference =""
    try{
      val resultJson = JSONObject(result)
      transactionStatus = resultJson.getString("Status")
      reference = resultJson.getString("RefNo")}
    catch (e:java.lang.Exception) {
      Toast.makeText(context," Card transaction failed",Toast.LENGTH_LONG).show()

   //   ErrorDisplayDialog.newInstance("Card transaction failed","unknown error").show(supportFragmentManager,"error")
      return
    }
    if (transactionStatus=="AUTHRECEIVED"){
      Toast.makeText(context," gotoPaymentDoneScreen",Toast.LENGTH_LONG).show()
   /*   gotoPaymentDoneScreen(reference,PaymentFlowDone.TransactionType.typeCreditCard.name,""+itemPrice,"John Doe",
        currencyTV)*/
    } else {
      Toast.makeText(context," Card transaction status",Toast.LENGTH_LONG).show()

      //ErrorDisplayDialog.newInstance("Card transaction status",transactionStatus).show(supportFragmentManager,"error")
    }
    transactionRefNo = ""
    //saveRefNO()
    Toast.makeText(context," saveRefNO",Toast.LENGTH_LONG).show()

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
    val threedsScreen = ThreedsManager(context,threedsUrl)
  //  threedsScreen.displayThreedsConfirmation(threedsReceiver)
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
}