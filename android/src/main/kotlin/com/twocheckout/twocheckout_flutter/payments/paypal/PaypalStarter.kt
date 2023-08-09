package com.twocheckout.twocheckout_flutter.payments.paypal

import android.content.Context
import android.content.Intent
import androidx.activity.result.ActivityResultLauncher
import androidx.appcompat.app.AppCompatActivity

class PaypalStarter(ctx: Context, paypalURL: String) {
    companion object{
        const val keyPaypalURL = "threeds_url"
        const val keyRefNO = "ref_no_value"
        const val paypalResultCode = 201

    }

    private val mCtx = ctx
    private var screenURL = ""

    init {
        ctx as AppCompatActivity
        screenURL = paypalURL
    }

    fun displayPaypalScreen(resultReceiver: ActivityResultLauncher<Intent>) {
        val temp = Intent(mCtx, PaypalWebScreen::class.java)
        temp.putExtra(keyPaypalURL,screenURL)
        resultReceiver.launch(temp)
    }
}