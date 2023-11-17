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
import com.twocheckout.twocheckout_flutter.Model.AuthorizePayment
import com.twocheckout.twocheckout_flutter.Model.CardFactory
import com.twocheckout.twocheckout_flutter.Model.Configuration
import com.twocheckout.twocheckout_flutter.datapack.FormUICustomizationData
import com.twocheckout.twocheckout_flutter.datapack.PaymentConfigurationData
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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.*
import kotlin.math.roundToInt


/** TwocheckoutFlutterPlugin */
class TwocheckoutFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity

    private var redirectUrl = ""
    private var selectedPaymentMethod = ""


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, Configuration.channelName)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}
    private fun showLoadingSpinner() {}
    private fun dismissLoadingSpinner() {}

    private fun invokeErrorFound(message: String) {
        CoroutineScope(Dispatchers.Main).launch {
            val arguments = hashMapOf<String, String>()
            arguments["error"] = message
            channel.invokeMethod(OutputMethod.PAYMENT_FAILED_WITH_ERROR, arguments)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            InputMethod.CREATE_TOKEN-> {
                val arguments: Map<String, Any>? = call.arguments()
                arguments?.let {
                    val card = CardFactory.createCardFromMap(arguments)
                    TwoCheckoutPaymentForm.getCardPaymentToken(Configuration.merchantCode, card, onTokenReady = {
                        val arguments = hashMapOf<String, Any>()
                        if (it.isEmpty()) {
                            arguments["error"] = "There is something wrong, Please try again later"
                        } else {
                            arguments["token"] = it
                        }
                        result.success(arguments)
                    })
                }
            }

            InputMethod.SET_2CHECKOUT_CREDENTIALS-> {
                val arguments: Map<String, Any>? = call.arguments()
                arguments?.let {
                    Configuration.fromMap(it)
                }
            }

            InputMethod.SHOW_PAYMENT_METHODS-> {
                val arguments: Map<String, Any>? = call.arguments()
                arguments?.let {
                    Configuration.updatePaymentDetails(it)
                }

                if (Configuration.secretKey.isEmpty() && Configuration.merchantCode.isEmpty()) {
                    invokeErrorFound("secretKey or merchantCode is missing")
                } else {
                    showPaymentOptions()
                }
            }

            InputMethod.AUTHORIZE_PAYMENT-> {
                val arguments: Map<String, Any>? = call.arguments()
                arguments?.let {
                    AuthorizePayment.fromMap(it)
                }

                if (AuthorizePayment.url.isEmpty() && AuthorizePayment.parameters.isEmpty()) {
                    invokeErrorFound("Authorize payment redirect url or parameters is missing")
                } else {
                    if (selectedPaymentMethod == "Paypal") {
                        startPaypalAuthScreen(AuthorizePayment.url)
                    } else {
                        startCardAuthScreen("${AuthorizePayment.url}?${AuthorizePayment.parameters.map{ "${it.key}=${it.value}" }.joinToString("&")}")
                    }
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun showPaymentOptions() {
        val payOptionsList = ArrayList<String>(2)
        payOptionsList.add(TwoCheckoutPaymentOptions.paymentOptionCard)
        payOptionsList.add(TwoCheckoutPaymentOptions.paymentOptionPayPal)

        val paymentOptionsSheet =
            TwoCheckoutPaymentOptions(activity , payOptionsList, ::onPayMethodSelected)
        paymentOptionsSheet.showPaymentOptionList()
    }

    private fun onPayMethodSelected(payMethod: String) {
        if (payMethod == TwoCheckoutPaymentOptions.paymentOptionPayPal) {
            selectedPaymentMethod = "Paypal"
            invokePaymentFormComplete("")
        } else if (payMethod == TwoCheckoutPaymentOptions.paymentOptionCard) {
            selectedPaymentMethod = "Credit Card"
            gotoCardFormPayment()
        }

        val arguments = hashMapOf<String, String>()
        arguments["paymentMethod"] = selectedPaymentMethod
        channel.invokeMethod(OutputMethod.PAYMENT_METHOD_SELECTED, arguments)
    }

    private fun gotoCardFormPayment() {
        val formConfigData = PaymentConfigurationData(
            activity,
            "${(Configuration.price * 100.0).roundToInt() / 100.0} ${Configuration.currency}",
            Configuration.merchantCode,
            FormUICustomizationData()
        )
        val cardPaymentForm = TwoCheckoutPaymentForm(
            formConfigData, ::showLoadingSpinner,
            ::onCreditCardInput
        )
        cardPaymentForm.displayPaymentForm()
    }

    private fun onCreditCardInput(cardPaymentToken: String) {
        dismissLoadingSpinner()
        if (cardPaymentToken.isEmpty()) {
            invokeErrorFound("Get card token is failed.")
            return
        }

        invokePaymentFormComplete(cardPaymentToken)
    }

    private fun invokePaymentFormComplete(token: String) {
        CoroutineScope(Dispatchers.Main).launch {
            val arguments = hashMapOf<String, Any>()
            arguments["cardHolder"] = ""
            arguments["paymentMethod"] = selectedPaymentMethod
            arguments["token"] = token
            arguments["isCardSaveOn"] = false
            channel.invokeMethod(OutputMethod.PAYMENT_FORM_COMPLETE, arguments)
        }
    }

    private fun startCardAuthScreen(threadUrl: String) {
        redirectUrl = threadUrl
        val temp = Intent(context, ThreedsAuthForm::class.java)
        temp.putExtra(ThreedsManager.keyThreedsURL, redirectUrl)
        activity.startActivityForResult(temp, threedsResultCode)
    }

    private fun startPaypalAuthScreen(paypalUrl: String) {
        redirectUrl = paypalUrl

        val temp = Intent(context, PaypalWebScreen::class.java)
        temp.putExtra(PaypalStarter.keyPaypalURL, paypalUrl)
        activity.startActivityForResult(temp, paypalResultCode)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == threedsResultCode || requestCode == paypalResultCode) {
            val refNO = if (selectedPaymentMethod == "Paypal") {
                data?.getStringExtra(PaypalStarter.keyRefNO) ?: ""
            } else {
                data?.getStringExtra(ThreedsManager.keyRefNO) ?: ""
            }
            if (refNO.isNotEmpty()) {
                val arguments = hashMapOf<String, Any>()
                arguments["redirectedUrl"] = redirectUrl
                val queryStringDictionary = hashMapOf<String, String>()
                queryStringDictionary["REFNO"] = refNO
                arguments["queryStringDictionary"] = queryStringDictionary
                channel.invokeMethod(OutputMethod.AUTHORIZE_PAYMENT_DID_COMPLETE, arguments)
            } else {
                invokeErrorFound("Payment transaction failed, Reference number not found")
            }
        }
        return false
    }

}