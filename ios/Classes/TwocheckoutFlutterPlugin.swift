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
        case InputMethod.SET_2CHECKOUT_CREDENTIALS:
            if let arguments = call.arguments as? [String : Any] {
                Configuration.shared.fromMap(arguments)
            }
        case InputMethod.SHOW_PAYMENT_METHODS:
            if let arguments = call.arguments as? [String : Any] {
                Configuration.shared.updatePaymentDetails(arguments)
                
                guard !Configuration.shared.secretKey.isEmpty, !Configuration.shared.merchantCode.isEmpty else {
                    print("secretKey or merchantCode is missing")
                    return
                }
                
                showPaymentOptions()
            }
        case InputMethod.AUTHORIZE_PAYMENT:
            print(call.arguments)
//            let webConfig = VFWebConfig(url: "RedirectURL",
//                                        parameters: ["Required parameters"],
//                                        expectedRedirectUrl: ["expectedReturnURL"],
//                                        expectedCancelUrl: ["expectedCancelURL"])
//            Verifone2COPaymentForm.authorizePayment(webConfig: webConfig, delegate: self, from: self)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func showPaymentOptions() {
        let paymentConfiguration: Verifone2CO.PaymentConfiguration = Verifone2CO.PaymentConfiguration(
            delegate: self,
            merchantCode: Configuration.shared.merchantCode,
            paymentPanelStoreTitle: "Store",
            totalAmount: String(format: "%.2f", Configuration.shared.price) + " " + Configuration.shared.currency,
            allowedPaymentMethods: [.creditCard, .paypal])
        Verifone2CO.locale = Locale(identifier: Configuration.shared.local)
        
        guard let controller = getRootViewController() else { return }
        rootViewController = controller
        Verifone2COPaymentForm.present(with: paymentConfiguration, from: controller)
    }
}

extension TwocheckoutFlutterPlugin: PaymentFlowSessionDelegate {
    public func paymentFormWillShow() {
        print("Payment form will be displayed")
    }
    
    public func paymentFormWillClose() {
        print("Payment form will be hidden")
    }
    
    public func paymentMethodSelected(_ paymentMethod: PaymentMethodType) {
        print("Selected payment method: \(paymentMethod)")
    }
    
    public func paymentFormComplete(_ result: Result<PaymentFormResult, Error>) {
        switch result {
        case .success(let result):
            print(result)
            let dict: [String : Any] = [
                "cardHolder" : result.cardHolder ?? "",
                "paymentMethod" : result.paymentMethod.rawValue,
                "token" : result.token ?? "",
                "isCardSaveOn" : result.isCardSaveOn ?? false
            ]
            getChannel()?.invokeMethod(OutputMethod.PAYMENT_FORM_COMPLETE, arguments: dict)
        case .failure(let error):
            print("Payment failed with error: \(error)")
        }
    }
}

extension TwocheckoutFlutterPlugin: VF2COAuthorizePaymentControllerDelegate {
    public func authorizePaymentViewController(didCompleteAuthorizing result: PaymentAuthorizingResult) {
        print("authorizePaymentViewController")
    }
    
    public func authorizePaymentViewControllerDidCancel() {
        print("authorizePaymentViewControllerDidCancel")
    }
}
