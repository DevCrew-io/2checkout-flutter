//
//  Verifone2CO.swift
//  Verifone2CO
//
//  Created by Oraz Atakishiyev on 16.01.2023.
//

import Foundation

public final class Verifone2CO {
    static public weak var paymentConfiguration: PaymentConfiguration?

    static public var locale: Locale? {
        didSet {
            _ = createBundle()
        }
    }

    static let bundleIdentifier = "com.verifone2co.sdk"
    fileprivate static var bundle: Bundle = createBundle()

    private static func createBundle() -> Bundle {
        class Class {}
        guard let localizationBundle = Bundle(identifier: bundleIdentifier)
        else { return Bundle(for: Class.self) }

        guard let bundlePath = localizationBundle.path(forResource: currentLanguage(of: localizationBundle),
                ofType: "lproj"),
        let bundle = Bundle(path: bundlePath) else { return Bundle(for: Class.self) }
        return bundle
    }

    private static func currentLanguage(of bundle: Bundle) -> String {
        guard let locale = locale else {
            return String(Locale.current.identifier.prefix(2))
        }
        return locale.identifier
    }

    public static func getBundle() -> Bundle {
        return createBundle()
    }
}

extension Verifone2CO {
    public class PaymentConfiguration {
        weak var delegate: PaymentFlowSessionDelegate?

        public var merchantCode: String
        public var totalAmount: String
        public let paymentPanelStoreTitle: String
        public var allowedPaymentMethods: [PaymentMethodType] = [.creditCard]
        public var showCardSaveSwitch: Bool
        public var theme: Verifone2CO.Theme
        public var cardSecureEntryType: SecureTextEtryType

        public init(delegate: PaymentFlowSessionDelegate?, merchantCode: String, paymentPanelStoreTitle: String, totalAmount: String, allowedPaymentMethods: [PaymentMethodType], showCardSaveSwitch: Bool = true, theme: Verifone2CO.Theme = .defaultTheme, cardSecureEntryType: SecureTextEtryType = .none) {
            self.delegate = delegate
            self.merchantCode = merchantCode
            self.paymentPanelStoreTitle = paymentPanelStoreTitle
            self.totalAmount = totalAmount
            self.allowedPaymentMethods = allowedPaymentMethods
            self.showCardSaveSwitch = showCardSaveSwitch
            self.theme = theme
            self.cardSecureEntryType = cardSecureEntryType
        }
    }
}
