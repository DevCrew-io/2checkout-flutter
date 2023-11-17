//
//  InvokeMethods.kt
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

package com.twocheckout.twocheckout_flutter

interface InvokeMethods {}

object InputMethod: InvokeMethods {
    const val CREATE_TOKEN = "createToken"
    const val AUTHORIZE_PAYMENT = "authorizePayment"
    const val SHOW_PAYMENT_METHODS = "showPaymentMethods"
    const val SET_2CHECKOUT_CREDENTIALS = "setTwoCheckCredentials"
}

object OutputMethod: InvokeMethods {
    const val PAYMENT_FORM_WILL_SHOW = "paymentFormWillShow"
    const val PAYMENT_FORM_WILL_CLOSE = "paymentFormWillClose"
    const val PAYMENT_METHOD_SELECTED = "paymentMethodSelected"
    const val PAYMENT_FAILED_WITH_ERROR = "paymentFailedWithError"
    const val PAYMENT_FORM_COMPLETE = "paymentFormComplete"
    const val AUTHORIZE_PAYMENT_DID_COMPLETE = "authorizePaymentDidCompleteAuthorizing"
    const val AUTHORIZE_PAYMENT_DID_CANCEL = "authorizePaymentDidCancel"
}