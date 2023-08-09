package com.twocheckout.twocheckout_flutter.payments.card

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.io.*
import java.net.HttpURLConnection
import java.net.URL
import javax.net.ssl.HttpsURLConnection

internal class CardPaymentInit(onPaymentToken: (token:String) -> Unit) {

    companion object {
        private const val cardTokenURL = "https://2pay-api.2checkout.com/api/v1/tokens"
    }
    private val onPaymentTokenSend = onPaymentToken
    private val cardData:JSONObject = JSONObject()
    private var errorMessage = ""
    private var merchantCode = ""
    private var overrideURL = ""

    fun launchAPI(){
        MainScope().launch(Dispatchers.Default) {
            val result = httpGet()
        }
    }

    fun overrideTokenURL(urlParam:String){
        overrideURL = urlParam
    }

    fun inputCardNumber(cardNumber:String){
        cardData.put("creditCard", cardNumber)
    }

    fun inputCardExpiry(expiryDate:String){
        cardData.put("expirationDate", expiryDate)
    }

    fun inputCVV(cvvCode:String){
        cardData.put("cvv", cvvCode)
    }

    fun inputPayerName(name:String){
        cardData.put("name",name)
    }

    fun inputScope(scope:String){
        cardData.put("scope", scope)
    }

    fun inputMerchantCode(code:String){
        merchantCode = code
    }

    private suspend fun httpGet(): String {
        val inputStream:InputStream
        var result:String
        var url = URL(cardTokenURL)
        if(overrideURL.isNotEmpty()){
           try {
               url = URL(overrideURL)
           } catch (e:Exception){
               url = URL(cardTokenURL)
               e.printStackTrace()
           }
        }

        val httpsConnect:HttpsURLConnection = url.openConnection() as HttpsURLConnection
        httpsConnect.requestMethod = "POST"
        httpsConnect.doOutput = true
        httpsConnect.doInput = true
        httpsConnect.allowUserInteraction = true
        httpsConnect.setRequestProperty("Content-Type", "application/json;charset=UTF-8")
        httpsConnect.setRequestProperty("Accept", "application/json")
        httpsConnect.setRequestProperty("X-2Checkout-MerchantCode", merchantCode)

        val outStream: OutputStream = httpsConnect.outputStream
        val outStreamWriter = OutputStreamWriter(outStream, "UTF-8")
        outStreamWriter.write(cardData.toString())
        outStreamWriter.flush()
        outStreamWriter.close()
        outStream.close()

        try {
            httpsConnect.connect()
            inputStream = httpsConnect.inputStream
            result = convertInputStreamToString(inputStream)
            val resultJSON = JSONObject(result)
            onPaymentTokenSend(resultJSON.getString("token"))
            inputStream.close()
        } catch (e:java.lang.Exception) {
            e.printStackTrace()
            errorMessage = convertInputStreamToString(httpsConnect.errorStream)
            result = ""
            onPaymentTokenSend(result)
        }

        httpsConnect.disconnect()
        return result
    }

    private fun convertInputStreamToString(inputStreamParam: InputStream):String{
        val reader = BufferedReader(inputStreamParam.reader())
        var content: String
        content = ""
        reader.use { reader ->
            content = reader.readText()
        }
        return content
    }
}