//
//  PaymentFlowSessionDeletage.swift
//  Verifone2CO
//

import Foundation

public struct PaymentFormResult {
    public let token: String?
    public let isCardSaveOn: Bool?
    public let cardHolder: String?
    public let paymentMethod: PaymentMethodType

    init(token: String, isCardSaveOn: Bool, cardHolder: String, paymentMethod: PaymentMethodType) {
        self.token = token
        self.isCardSaveOn = isCardSaveOn
        self.cardHolder = cardHolder
        self.paymentMethod = paymentMethod
    }

    init(paymentMethod: PaymentMethodType) {
        self.paymentMethod = paymentMethod
        self.token = nil
        self.isCardSaveOn = nil
        self.cardHolder = nil
    }
}

public protocol PaymentFlowSessionDelegate: AnyObject {
    func paymentFormWillShow()
    func paymentFormWillClose()
    func paymentMethodSelected(_ paymentMethod: PaymentMethodType)
    func paymentFormComplete(_ result: Result<PaymentFormResult, Error>)
}
