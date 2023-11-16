package com.twocheckout.twocheckout_flutter.payments.card

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsManager.Companion.keyRefNO
import com.twocheckout.twocheckout_flutter.R
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsManager.Companion.keyThreedsURL
import com.twocheckout.twocheckout_flutter.payments.card.ThreedsManager.Companion.threedsResultCode

internal class ThreedsAuthForm : AppCompatActivity() {

    private lateinit var threedsWebView: WebView
    private var urlToLoad = ""

    private lateinit var mThreedsWebClient:ThreedsWebClient

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.threeds_screen_layout)
        threedsWebView = findViewById(R.id.threeds_web_view)
        urlToLoad = intent.getStringExtra(keyThreedsURL)?:""
        mThreedsWebClient = ThreedsWebClient(::onThreedsFlowDone)
        threedsWebView.webViewClient = mThreedsWebClient
        threedsWebView.settings.javaScriptEnabled = true
        threedsWebView.loadUrl(urlToLoad)
    }

    private fun onThreedsFlowDone(result:MutableMap<String, String>){
        for (idx in result){
            if (idx.key == "REFNO") {
                val resultData = Intent()
                resultData.putExtra(keyRefNO,idx.value)
                setResult(threedsResultCode,resultData)
                finish()
                break
            }
        }
    }

}