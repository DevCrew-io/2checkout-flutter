//
//  VerifonePaymentForm.swift
//  Verifone2CO
//

import UIKit

public class Verifone2COPaymentForm: BaseFormViewController {
    // MARK: - PROPERTIES
    internal var paymentConfiguration: Verifone2CO.PaymentConfiguration!
    internal let networkManager: NetworkManager! = NetworkManager()

    // MARK: - PRESENT PAYMENT FORM
    @discardableResult
    public class func present(with configuration: Verifone2CO.PaymentConfiguration, from: UIViewController) -> Verifone2COPaymentForm? {
        let controller = PaymentMethodsForm.present(
            with: configuration, from: from) as! PaymentMethodsForm
        configuration.delegate?.paymentFormWillShow()
        controller.selectedPaymentMethod = { paymentMethod in
            configuration.delegate?.paymentMethodSelected(paymentMethod)
            switch paymentMethod {
            case .creditCard:
                guard !configuration.merchantCode.isEmpty else {
                    self.handleErrorDelegate(
                        with: configuration, error: Verifone2CoError.requiredParams("merchant code"))
                    return
                }
                self.showCreditCardForm(with: configuration, from: from)
            case .paypal:
                let result = PaymentFormResult(paymentMethod: .paypal)
                configuration.delegate?.paymentFormComplete(.success(result))
                configuration.delegate?.paymentFormWillClose()
            }
        }
        return controller
    }

    internal func presentPan(from controller: UIViewController) {
        controller.presentPanModal(self)
    }

    internal func presentDefault(from controller: UIViewController) {
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        controller.present(self, animated: true)
    }

    // MARK: - FINISH WITH ERROR
    private class func handleErrorDelegate(with configuration: Verifone2CO.PaymentConfiguration, error: Verifone2CoError) {
        configuration.delegate?.paymentFormComplete(.failure(error))
        configuration.delegate?.paymentFormWillClose()
    }

    /// SHOW CREDIT CARD FORM
    @discardableResult
    private class func showCreditCardForm(with configuration: Verifone2CO.PaymentConfiguration, from: UIViewController) -> Verifone2COPaymentForm {
        let controller = CreditCardFormViewController.present(with: configuration, from: from) as! CreditCardFormViewController
        controller.onPayPressed = { card, isCardSaveOn in
            PaymentProgress.present(paymentConfiguration: configuration, card: card, isCardSaveOn: isCardSaveOn, from: from)
        }
        return controller
    }

    /// CREATE A TOKEN
    func cardTokenisation(card: Card, completion: @escaping (Token?, Error?) -> Void) {
        let headers = [
            "Accept": "application/json, text/plain",
            "Content-Type": "application/json;charset=UTF-8",
            HeaderKeyMerchantCode: self.paymentConfiguration.merchantCode
        ]
        self.networkManager.createToken(headers: headers, params: card.dictionary) { token, error in
            completion(token, error)
        }
    }

    /// WEBVIEW AUTHORIZE PAYMENT
    @discardableResult
    public class func authorizePayment(webConfig: VFWebConfig, delegate: VF2COAuthorizePaymentControllerDelegate, from: UIViewController) -> Verifone2COPaymentForm {
        let authorizeWebview = VF2COAuthorizePaymentController(webConfig: webConfig)
        authorizeWebview.delegate = delegate
        authorizeWebview.presentPan(from: from)
        return authorizeWebview
    }
}

extension Verifone2COPaymentForm {
    public static func createToken(merchantCode: String, card: Card, completion: @escaping (Token?, Error?) -> Void) {
        let headers = [
            "Accept": "application/json, text/plain",
            "Content-Type": "application/json;charset=UTF-8",
            HeaderKeyMerchantCode: merchantCode
        ]
        let networkManager: NetworkManager = NetworkManager()
        networkManager.createToken(headers: headers, params: card.dictionary) { token, error in
            completion(token, error)
        }
    }
}
