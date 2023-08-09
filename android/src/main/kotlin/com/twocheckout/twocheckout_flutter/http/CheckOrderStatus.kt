package com.twocheckout.twocheckout_flutter.http

import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStream
import java.io.OutputStream
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import javax.net.ssl.HttpsURLConnection

class CheckOrderStatus(onCheckOrderComplete: (response:String) -> Unit) {
    companion object {
        private const val orderStatusUrl = "https://api.2checkout.com/rest/6.0/orders/"


    }
    private val sendCheckStatus = onCheckOrderComplete
    private lateinit var httpsConnect: HttpsURLConnection

    private var errorMessage = ""
    lateinit var authHeaders:HashMap<String, String>

    private fun setupAuthenticationHeaders() {
        for (ind in authHeaders) {
            httpsConnect.setRequestProperty(ind.key, ind.value)
        }
    }

    fun launchAPI(refParam:String) {
        val coroutineExceptionHandler = CoroutineExceptionHandler{_, throwable ->
            throwable.printStackTrace()
        }
        MainScope().launch(Dispatchers.Default + coroutineExceptionHandler) {
            checkOrdersAPI(refParam)
        }
    }

    private fun checkOrdersAPI(reference:String) {
        val inputStream: InputStream
        val checkStatusUrl = "$orderStatusUrl$reference/"
        val url = URL(checkStatusUrl)
        httpsConnect = url.openConnection() as HttpsURLConnection
        httpsConnect.requestMethod = "GET"
        setupAuthenticationHeaders()

        try {
            httpsConnect.connect()
            inputStream = httpsConnect.inputStream
            val result = convertInputStreamToString(inputStream)
            sendCheckStatus(result)
            inputStream.close()
        } catch (e:java.lang.Exception) {
            e.printStackTrace()
            errorMessage = convertInputStreamToString(httpsConnect.errorStream)

        }

    }

    private fun addRequestBody(refNO:String) {
        val requestBody = JSONObject()

        requestBody.put("ApproveStatus", "OK")
        requestBody.put("Newer", "")
        requestBody.put( "Status", "")

        requestBody.put("StartDate", "")
        requestBody.put("EndDate", "")

        requestBody.put("PartnerOrders", false)
        requestBody.put("ExternalRefNo", refNO)

        requestBody.put("Page", "")
        requestBody.put("WSOrder", "testvendorOrder.com")
        requestBody.put("Limit",0)


        val outStream: OutputStream = httpsConnect.outputStream
        val outStreamWriter = OutputStreamWriter(outStream, "UTF-8")
        outStreamWriter.write(requestBody.toString())
        outStreamWriter.flush()
        outStreamWriter.close()
        outStream.close()
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
}