//
//  InvokeMethods.swift
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

import Foundation

protocol InvokeMethods {}

enum InputMethod: InvokeMethods {
    static let CREATE_TOKEN = "createToken"
    static let AUTHORIZE_PAYMENT = "authorizePayment"
    static let SHOW_PAYMENT_METHODS = "showPaymentMethods"
    static let SET_2CHECKOUT_CREDENTIALS = "setTwoCheckCredentials"
}

enum OutputMethod: InvokeMethods {
    static let PAYMENT_FORM_WILL_SHOW = "paymentFormWillShow"
    static let PAYMENT_FORM_WILL_CLOSE = "paymentFormWillClose"
    static let PAYMENT_METHOD_SELECTED = "paymentMethodSelected"
    static let PAYMENT_FAILED_WITH_ERROR = "paymentFailedWithError"
    static let PAYMENT_FORM_COMPLETE = "paymentFormComplete"
    static let AUTHORIZE_PAYMENT_DID_COMPLETE = "authorizePaymentDidCompleteAuthorizing"
    static let AUTHORIZE_PAYMENT_DID_CANCEL = "authorizePaymentDidCancel"
}
