package com.twocheckout.twocheckout_flutter.payments.card


import android.content.Context
import android.content.Intent
import androidx.activity.result.ActivityResult
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentManager

class ThreedsManager(ctx: Context, displayURL: String) {

    companion object{
        const val keyThreedsURL = "threeds_url"
        const val keyRefNO = "ref_no_value"
        const val threedsResultCode = 4323

    }


    private var mFragmentManager: FragmentManager
    private val mCtx = ctx
    private var screenURL = ""

    init {
        ctx as AppCompatActivity
        mFragmentManager = ctx.supportFragmentManager
        screenURL = displayURL
    }

    fun displayThreedsConfirmation(threedsReceiver:ActivityResultLauncher<Intent>) {
        val temp = Intent(mCtx,ThreedsAuthForm::class.java)
        temp.putExtra(keyThreedsURL,screenURL)
        threedsReceiver.launch(temp)
    }

}