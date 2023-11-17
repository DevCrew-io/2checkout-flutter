package com.twocheckout.twocheckout_flutter.payments.card


import android.graphics.Bitmap
import android.util.Log

import android.webkit.WebView
import android.webkit.WebViewClient
import java.net.URI
import java.net.URL
import java.net.URLDecoder

internal class ThreedsWebClient(onConfirmationDone: (MutableMap<String, String>) -> Unit): WebViewClient() {
    val sendConfirmationResult = onConfirmationDone
    override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
        val sourceURL = url.toString()
        if (sourceURL.isNotEmpty()&&sourceURL.contains("REFNO")) {
            sendConfirmationResult(parseQueryParams(URL(url)))
            return
        }
    }

    override fun onLoadResource(view: WebView?, url: String?) {
        super.onLoadResource(view, url)
    }

    private fun parseQueryParams(urlParam:URL):MutableMap<String, String> {
        val queryPairs: MutableMap<String, String> = LinkedHashMap()
        val query: String = urlParam.query
        val pairs = query.split("?").toTypedArray()
        for (pair in pairs) {
            val idx = pair.indexOf("=")
            queryPairs[URLDecoder.decode(pair.substring(0, idx), "UTF-8")] =
                URLDecoder.decode(pair.substring(idx + 1), "UTF-8")
        }
        return queryPairs
    }

    private fun isValidUrl(url: String?):Boolean {
        val uri = URI(url)
        val domain: String = uri.host
        return domain.contains("avancart")
    }

}