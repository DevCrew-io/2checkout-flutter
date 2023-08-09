package com.twocheckout.twocheckout_flutter.screens


import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.*
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.twocheckout.twocheckout_flutter.R


internal class PaymentOptionsDialog(displayOptionsParam: ArrayList<String>,onPayMethodSelected:(payMethod:String) -> Unit,ctx: Context): Dialog(ctx) {
    private lateinit var mCardOptionBtn:ConstraintLayout
    private lateinit var mPaypalOptionBtn:ConstraintLayout
    private lateinit var mGooglePayOptionBtn:ConstraintLayout
    private lateinit var mCloseBtn:AppCompatImageView

    val payMethodSelected = onPayMethodSelected
    val paymentOptionButtons = ArrayList<ConstraintLayout>(2)
    val paymentOptionImages = ArrayList<AppCompatImageView>(2)
    val paymentOptionTexts = ArrayList<AppCompatTextView>(2)
    val selectedPaymentOptions = displayOptionsParam
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.payment_options_layout)
        window?.setLayout(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT)
        window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        paymentOptionButtons.add(findViewById(R.id.pay_option_container1))
        paymentOptionButtons.add(findViewById(R.id.pay_option_container2))
        paymentOptionButtons.add(findViewById(R.id.pay_option_container3))

        paymentOptionImages.add(findViewById(R.id.pay_option_image1))
        paymentOptionImages.add(findViewById(R.id.pay_option_image2))
        paymentOptionImages.add(findViewById(R.id.pay_option_image3))

        paymentOptionTexts.add(findViewById(R.id.pay_option_text1))
        paymentOptionTexts.add(findViewById(R.id.pay_option_text2))
        paymentOptionTexts.add(findViewById(R.id.pay_option_text3))


        mCloseBtn = findViewById(R.id.close_btn)
        mCloseBtn.setOnClickListener {
            dismiss()
        }

        setupSelectedPayOptions(selectedPaymentOptions)

    }
    private fun setupSelectedPayOptions(displayOptions: ArrayList<String>) {

        for ((i, index) in displayOptions.withIndex()) {
            if (index == TwoCheckoutPaymentOptions.paymentOptionCard) {
                mCardOptionBtn = paymentOptionButtons[i]
                mCardOptionBtn.visibility = View.VISIBLE
                mCardOptionBtn.setOnClickListener {
                    payMethodSelected(TwoCheckoutPaymentOptions.paymentOptionCard)
                    dismiss()
                }
                paymentOptionTexts[i].setText(R.string.paymentProductTitleCard)
                paymentOptionImages[i].setImageResource(R.drawable.card_symbol)
            } else if (index == TwoCheckoutPaymentOptions.paymentOptionPayPal) {
                mPaypalOptionBtn = paymentOptionButtons[i]
                mPaypalOptionBtn.visibility = View.VISIBLE
                mPaypalOptionBtn.setOnClickListener {
                    payMethodSelected(TwoCheckoutPaymentOptions.paymentOptionPayPal)
                    dismiss()
                }
                paymentOptionTexts[i].setText(R.string.paymentProductTitlePaypal)
                paymentOptionImages[i].setImageResource(R.drawable.paypal_logo)
            } else if (index == TwoCheckoutPaymentOptions.paymentOptionGooglePay){
                mGooglePayOptionBtn = paymentOptionButtons[i]
                mGooglePayOptionBtn.visibility = View.VISIBLE
                mGooglePayOptionBtn.setOnClickListener {

                    payMethodSelected(TwoCheckoutPaymentOptions.paymentOptionGooglePay)
                    dismiss()
                }
                paymentOptionTexts[i].setText(R.string.paymentProductTitleGooglePay)
                paymentOptionImages[i].setImageResource(R.drawable.sv_google_pay_logo)

            }
        }
    }

}