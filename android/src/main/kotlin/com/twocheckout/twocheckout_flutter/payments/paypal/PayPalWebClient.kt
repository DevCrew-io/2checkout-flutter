package com.twocheckout.twocheckout_flutter.payments.paypal

import android.graphics.Bitmap
import android.webkit.WebView
import android.webkit.WebViewClient
import java.net.URI
import java.net.URL
import java.net.URLDecoder

class PayPalWebClient(onConfirmationDone: (MutableMap<String, String>) -> Unit): WebViewClient() {
    val sendConfirmationResult = onConfirmationDone
    override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
        val sourceURL = url.toString()
        if (sourceURL.isNotEmpty()&&sourceURL.contains("refNo")) {
            sendConfirmationResult(parseQueryParams(URL(url)))
            return
        }
    }

    override fun onLoadResource(view: WebView?, url: String?) {
        super.onLoadResource(view, url)
    }

    override fun onPageFinished(view: WebView?, url: String?) {
        super.onPageFinished(view, url)
        if(url!=null && url.contains("status")){
            sendConfirmationResult(parseQueryParams(URL(url)))
        }
    }

    private fun parseQueryParams(urlParam: URL):MutableMap<String, String> {
        val queryPairs: MutableMap<String, String> = LinkedHashMap()
        val query: String = urlParam.query
        val pairs = query.split("&").toTypedArray()
        for (pair in pairs) {
            if (pair.contains("=")){
            val idx = pair.indexOf("=")
            queryPairs[URLDecoder.decode(pair.substring(0, idx), "UTF-8")] =
                URLDecoder.decode(pair.substring(idx + 1), "UTF-8")
            }
        }
        return queryPairs
    }
}