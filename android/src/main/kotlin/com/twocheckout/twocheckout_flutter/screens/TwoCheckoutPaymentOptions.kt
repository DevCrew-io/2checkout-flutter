package com.twocheckout.twocheckout_flutter.screens
import android.app.Activity
import android.content.Context


class TwoCheckoutPaymentOptions(ctx:Context, displayMethods: ArrayList<String>, onPaymentOptionSelected:(paymentOption:String) -> Unit) {
    companion object {
        const val paymentOptionCard = "credit_card_3ds"
        const val paymentOptionPayPal = "payPal"
        internal const val paymentOptionGooglePay = "googlePay"

    }
    private val mCtx = ctx
    private val onSelectedMethod = onPaymentOptionSelected
    private val displayPayMethods = displayMethods
    private lateinit var payOptionsDialog:PaymentOptionsDialog

    fun showPaymentOptionList() {
        payOptionsDialog = PaymentOptionsDialog(displayPayMethods,onSelectedMethod,mCtx)
        payOptionsDialog.setOwnerActivity(mCtx as Activity)
        payOptionsDialog.show()
    }
}