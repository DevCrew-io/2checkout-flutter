package com.twocheckout.twocheckout_flutter.payments.paypal

import android.content.Intent
import android.os.Bundle
import android.webkit.WebView
import androidx.appcompat.app.AppCompatActivity
import com.twocheckout.twocheckout_flutter.R
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsManager

internal class PaypalWebScreen:AppCompatActivity() {
    private lateinit var paypalWebView: WebView
    private var urlToLoad = ""

    private lateinit var mPaypalWebClient: PayPalWebClient

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.threeds_screen_layout)
        paypalWebView = findViewById(R.id.threeds_web_view)
        urlToLoad = intent.getStringExtra(ThreedsManager.keyThreedsURL)?:""
        mPaypalWebClient = PayPalWebClient(::onPaypalFlowDone)
        paypalWebView.webViewClient = mPaypalWebClient
        paypalWebView.settings.javaScriptEnabled = true
        paypalWebView.loadUrl(urlToLoad)
    }

    private fun onPaypalFlowDone(result:MutableMap<String, String>){
        val resultData = Intent()
        var tempRefNO = ""
        for (idx in result){
            if (idx.key == "refNo") {
                tempRefNO = idx.value
                break
            }
        }
        resultData.putExtra(PaypalStarter.keyRefNO,tempRefNO)
        setResult(PaypalStarter.paypalResultCode,resultData)
        finish()
    }
}