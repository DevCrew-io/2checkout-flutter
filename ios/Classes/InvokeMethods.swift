import Foundation

protocol InvokeMethods {}

enum InputMethod: InvokeMethods {
    static let AUTHORIZE_PAYMENT = "authorizePayment"
    static let SHOW_PAYMENT_METHODS = "showPaymentMethods"
    static let SET_2CHECKOUT_CREDENTIALS = "setTwoCheckCredentials"
}

enum OutputMethod: InvokeMethods {
    static let SHOW_LOADING_SPINNER = "showLoadingSpinner"
    static let ALERT_DIALOG = "showFlutterAlert"
    static let DISMISS_LOADING_SPINNER = "dismissProgressbar"
    static let PAYMENT_FLOW_DONE = "PaymentFlowDone"
    static let API_RESPONSE = "apiResponse"
    static let PAYMENT_FORM_COMPLETE = "paymentFormComplete"

}
