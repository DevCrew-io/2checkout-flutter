package com.twocheckout.twocheckout_flutter.http

import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStream
import java.io.OutputStream
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import javax.net.ssl.HttpsURLConnection
import kotlin.collections.HashMap

class OrdersCardPaymentAPI(currency:String,isPaypal:Boolean, onSendResultComplete: (response:String) -> Unit) {
    companion object {
        private const val cardPaymentsURL = "https://api.2checkout.com/rest/6.0/orders/"
    }
    private lateinit var httpsConnect: HttpsURLConnection
    private val currencyVal = currency
    private var errorMessage = ""
    lateinit var authHeaders:HashMap<String, String>
    private var overridePaymentsURL = ""
    private val onSendResult = onSendResultComplete
    private val isPaypalTransaction = isPaypal
    private fun setupAuthenticationHeaders() {
        for (ind in authHeaders) {
            httpsConnect.setRequestProperty(ind.key, ind.value)
        }
    }

    fun overridePaymentURL(newPaymentsUrl:String){
        overridePaymentsURL = newPaymentsUrl
    }

    private fun convertInputStreamToString(inputStreamParam: InputStream):String{
        if (inputStreamParam == null) return ""
        val reader = BufferedReader(inputStreamParam.reader())
        var content: String
        content = ""
        reader.use { reader ->
            content = reader.readText()
        }
        return content
    }

    fun launchAPI(tokenEES:String){
        val coroutineExceptionHandler = CoroutineExceptionHandler{_, throwable ->
            throwable.printStackTrace()
        }
        MainScope().launch(Dispatchers.Default + coroutineExceptionHandler) {
            postOrdersAPI(tokenEES)
        }
    }

    private fun postOrdersAPI(tokenEES:String) {
        val inputStream: InputStream
        var url = URL(cardPaymentsURL)
        if (overridePaymentsURL.isNotEmpty()) {
            url = try{
                URL(overridePaymentsURL)
            }catch (e:Exception){
                e.printStackTrace()
                URL(cardPaymentsURL)
            }
        }

        httpsConnect = url.openConnection() as HttpsURLConnection
        httpsConnect.requestMethod = "POST"
        httpsConnect.doOutput = true
        httpsConnect.doInput = true
        httpsConnect.allowUserInteraction = true
        setupAuthenticationHeaders()
        addRequestBody(tokenEES)
        try {
            httpsConnect.connect()
            inputStream = httpsConnect.inputStream
            val result = convertInputStreamToString(inputStream)
            onSendResult(result)

            inputStream.close()
        } catch (e:java.lang.Exception) {
            e.printStackTrace()
            errorMessage = convertInputStreamToString(httpsConnect.errorStream)
            onSendResult("")
        }

        httpsConnect.disconnect()
    }

    private fun addRequestBody(tokenParam:String) {
        val requestBody = JSONObject()
        requestBody.put("Country", "BR")
        requestBody.put("Currency", currencyVal)
        requestBody.put( "CustomerIP", "91.220.121.21")
        requestBody.put("CustomerReference", "GFDFE")
        requestBody.put("ExternalCustomerReference", "IOUER")
        requestBody.put("ExternalReference", "REST_API_AVANGTE")
        requestBody.put("Language", "en")
        requestBody.put("Source", "testAPI.com")
        requestBody.put("WSOrder", "testvendorOrder.com")
        requestBody.put("Affiliate",null)
        requestBody.put("BillingDetails",getBillingDetailsJson())
        requestBody.put("PaymentDetails",addPaymentDetails(tokenParam))
        val itemsArray = JSONArray()
        itemsArray.put(addOrderItem())

        requestBody.put("Items",itemsArray)
        val outStream: OutputStream = httpsConnect.outputStream
        val outStreamWriter = OutputStreamWriter(outStream, "UTF-8")
        outStreamWriter.write(requestBody.toString())
        outStreamWriter.flush()
        outStreamWriter.close()
        outStream.close()
    }

    private fun getBillingDetailsJson():JSONObject {
        val billingDetails = JSONObject()
        billingDetails.put("Address1", "Test Address")
        billingDetails.put("City", "LA")
        billingDetails.put("CountryCode", "US")
        billingDetails.put("Email", "customer@2Checkout.com")
        billingDetails.put("FirstName", "Customer")
        billingDetails.put("LastName", "2Checkout")
        billingDetails.put("Phone", "556133127400")
        billingDetails.put("State", "DF")
        billingDetails.put("Zip", "70403-900")
        return billingDetails
    }

    private fun addOrderItem():JSONObject{
        val orderItem = JSONObject()
        orderItem.put("Quantity","1")
        orderItem.put("Name", "Dynamic product")
        orderItem.put("Description", "Test description")
        orderItem.put("IsDynamic", true)
        orderItem.put("Tangible", false)
        orderItem.put("PurchaseType", "PRODUCT")
        val price = JSONObject()
        price.put("Amount",0.01)
        orderItem.put("Price",price)
        return orderItem
    }

    private fun addPaymentDetails(eesToken:String):JSONObject {
        val paymentDetails = JSONObject()
        val paymentMethod = JSONObject()

        if (!isPaypalTransaction) {
            paymentMethod.put("EesToken", eesToken)
            paymentDetails.put("Type", "EES_TOKEN_PAYMENT")
            paymentMethod.put("Vendor3DSReturnURL", "www.test.com")
            paymentMethod.put("Vendor3DSCancelURL", "www.test.com")
        } else {
            paymentDetails.put("Type", "PAYPAL")
            paymentMethod.put("ReturnURL", "https://www.success.com")
            paymentMethod.put("CancelURL", "https://www.fail.com")
        }

        paymentDetails.put("Currency",currencyVal)
        paymentDetails.put("CustomerIP", "91.220.121.21")
        paymentDetails.put("PaymentMethod",paymentMethod)
        return paymentDetails
    }

}