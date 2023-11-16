//
//  TwocheckoutFlutterPlugin.swift
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

import Flutter
import UIKit

public class TwocheckoutFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Configuration.shared.channelName, binaryMessenger: registrar.messenger())
        let instance = TwocheckoutFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private var rootViewController = UIViewController()
    private func getRootViewController() -> FlutterViewController? {
        return UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController
    }
    
    private func getChannel() -> FlutterMethodChannel? {
        guard let contoller = getRootViewController() else { return nil }
        
        return FlutterMethodChannel(name: Configuration.shared.channelName, binaryMessenger: contoller.binaryMessenger)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case InputMethod.CREATE_TOKEN:
            if let arguments = call.arguments as? [String : Any] {
                let card = CardFactory.createCardFromMap(arguments)
                Verifone2COPaymentForm.createToken(merchantCode: Configuration.shared.merchantCode, card: card) { token, error in
                    result(["token" : token?.token,
                            "error" : error?.localizedDescription])
                }
            }
        case InputMethod.SET_2CHECKOUT_CREDENTIALS:
            if let arguments = call.arguments as? [String : Any] {
                Configuration.shared.fromMap(arguments)
            }
        case InputMethod.SHOW_PAYMENT_METHODS:
            if let arguments = call.arguments as? [String : Any] {
                Configuration.shared.updatePaymentDetails(arguments)
                
                guard !Configuration.shared.secretKey.isEmpty, !Configuration.shared.merchantCode.isEmpty else {
                    debugPrint("secretKey or merchantCode is missing")
                    getChannel()?.invokeMethod(OutputMethod.PAYMENT_FAILED_WITH_ERROR, arguments: ["error" : "secretKey or merchantCode is missing"])
                    return
                }
                
                showPaymentOptions()
            }
        case InputMethod.AUTHORIZE_PAYMENT:
            if let arguments = call.arguments as? [String : Any] {
                AuthorizePayment.shared.fromMap(arguments)
                
                guard !AuthorizePayment.shared.url.isEmpty, !AuthorizePayment.shared.parameters.isEmpty else {
                    getChannel()?.invokeMethod(OutputMethod.PAYMENT_FAILED_WITH_ERROR, arguments: ["error" : "Authorize payment redirect url or parameters is missing"])
                    return
                }
                
                Verifone2COPaymentForm.authorizePayment(webConfig: getAuthWebConfig(), delegate: self, from: rootViewController)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func showPaymentOptions() {
        let paymentConfiguration: Verifone2CO.PaymentConfiguration = Verifone2CO.PaymentConfiguration(
            delegate: self,
            merchantCode: Configuration.shared.merchantCode,
            paymentPanelStoreTitle: "Payment",
            totalAmount: String(format: "%.2f", Configuration.shared.price) + " " + Configuration.shared.currency,
            allowedPaymentMethods: [.creditCard, .paypal])
        Verifone2CO.locale = Locale(identifier: Configuration.shared.local)
        
        guard let controller = getRootViewController() else { return }
        rootViewController = controller
        Verifone2COPaymentForm.present(with: paymentConfiguration, from: controller)
    }
    
    func getAuthWebConfig() -> VFWebConfig {
        let expectedReturnURL = URLComponents(string: AuthorizePayment.shared.successReturnUrl)!
        let expectedCancelURL = URLComponents(string: AuthorizePayment.shared.cancelReturnUrl)!
        let webConfig = VFWebConfig(url: AuthorizePayment.shared.url,
                                    parameters: AuthorizePayment.shared.parameters,
                                    expectedRedirectUrl: [expectedReturnURL],
                                    expectedCancelUrl: [expectedCancelURL])
        return webConfig
    }
}

extension TwocheckoutFlutterPlugin: PaymentFlowSessionDelegate {
    public func paymentFormWillShow() {
        getChannel()?.invokeMethod(OutputMethod.PAYMENT_FORM_WILL_SHOW, arguments: nil)
    }
    
    public func paymentFormWillClose() {
        getChannel()?.invokeMethod(OutputMethod.PAYMENT_FORM_WILL_CLOSE, arguments: nil)
    }
    
    public func paymentMethodSelected(_ paymentMethod: PaymentMethodType) {
        getChannel()?.invokeMethod(OutputMethod.PAYMENT_METHOD_SELECTED, arguments: ["paymentMethod" : paymentMethod.rawValue])
    }
    
    public func paymentFormComplete(_ result: Result<PaymentFormResult, Error>) {
        switch result {
        case .success(let result):
            let dict: [String : Any] = [
                "cardHolder" : result.cardHolder ?? "",
                "paymentMethod" : result.paymentMethod.rawValue,
                "token" : result.token ?? "",
                "isCardSaveOn" : result.isCardSaveOn ?? false
            ]
            getChannel()?.invokeMethod(OutputMethod.PAYMENT_FORM_COMPLETE, arguments: dict)
        case .failure(let error):
            debugPrint("Payment failed with error: \(error)")
            getChannel()?.invokeMethod(OutputMethod.PAYMENT_FAILED_WITH_ERROR, arguments: ["error" : error.localizedDescription])
        }
    }
}

extension TwocheckoutFlutterPlugin: VF2COAuthorizePaymentControllerDelegate {
    public func authorizePaymentViewController(didCompleteAuthorizing result: PaymentAuthorizingResult) {
        let dict: [String : Any] = [
            "redirectedUrl" : result.redirectedUrl,
            "queryStringDictionary" : result.queryStringDictionary ?? [:]
        ]
        getChannel()?.invokeMethod(OutputMethod.AUTHORIZE_PAYMENT_DID_COMPLETE, arguments: dict)
    }
    
    public func authorizePaymentViewControllerDidCancel() {
        getChannel()?.invokeMethod(OutputMethod.AUTHORIZE_PAYMENT_DID_CANCEL, arguments: nil)
    }
}
