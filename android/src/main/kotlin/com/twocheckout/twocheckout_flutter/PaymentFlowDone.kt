//
//  TwocheckoutFlutterPlugin.kt
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//
package com.twocheckout.twocheckout_flutter

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.AppCompatButton
import androidx.appcompat.widget.AppCompatTextView

class PaymentFlowDone: AppCompatActivity() {
    enum class TransactionType {
        typeCreditCard,
        typePayPal
    }
    companion object {
        const val keyTransactionAmount = "transaction_amount_value"
        const val keyTransactionCurrency = "transaction_amount_currency"
        const val keyTransactionReference = "transaction_reference_value"
        const val keyTransactionType = "transaction_type"
        const val keyPayerName = "payer_name"
    }
    private lateinit var mPayerNameTV:AppCompatTextView
    private lateinit var mTransactionReferenceTV:AppCompatTextView
    private lateinit var mTransactionAmountTV:AppCompatTextView
    private lateinit var mTransactionAmountTopTV:AppCompatTextView
    private lateinit var mGoBackBtn:AppCompatButton
    private var mTransactionType =""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.payment_flow_done)
        mPayerNameTV = findViewById(R.id.customer_value_tv)
        mTransactionReferenceTV = findViewById(R.id.reference_value_tv)
        mTransactionAmountTV = findViewById(R.id.amount_value_tv)
        mTransactionAmountTopTV = findViewById(R.id.transaction_value_top)

        mGoBackBtn = findViewById(R.id.back_to_store)
        mGoBackBtn.setOnClickListener {
            finish()
        }

        mPayerNameTV.text = intent.getStringExtra(keyPayerName)

        mTransactionType = intent.getStringExtra(keyTransactionType)?:""
        val amountStr = intent.getStringExtra(keyTransactionAmount)
        val currency = intent.getStringExtra(keyTransactionCurrency)

        var fullDisplayVal = "$amountStr $currency"

        if (mTransactionType== TransactionType.typeCreditCard.name
            || mTransactionType== TransactionType.typePayPal.name) {
            fullDisplayVal = "$amountStr $currency"
        }


        mTransactionAmountTV.text = fullDisplayVal
        mTransactionReferenceTV.text = intent.getStringExtra(keyTransactionReference)
        mTransactionAmountTopTV.text = fullDisplayVal
    }
}