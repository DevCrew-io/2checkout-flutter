//
//  PaymentMethodType.swift
//  Verifone2CO
//

import Foundation

public enum PaymentMethodType: String, CaseIterable {
    case creditCard = "Credit Card"
    case paypal = "Paypal"

    static func build(rawValue: String) -> PaymentMethodType {
        return PaymentMethodType(rawValue: rawValue) ?? .creditCard
    }
}
