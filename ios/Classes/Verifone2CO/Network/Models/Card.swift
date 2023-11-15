//
//  Card.swift
//  Verifone2CO
//

import Foundation

public struct Card: Codable {
    private var name: String
    private var cvv: String
    private var creditCard: String
    private var expirationDate: String
    private var scope: String?

    public init(name: String, creditCard: String, cvv: String, expirationDate: String, scope: String? = nil) {
        self.name = name
        self.creditCard = creditCard
        self.cvv = cvv
        self.expirationDate = expirationDate
        self.scope = scope
    }

    var dictionary: [String: Any?] {
        return [
            "name": name,
            "creditCard": creditCard,
            "cvv": cvv,
            "expirationDate": expirationDate,
            "scope": scope
        ]
    }

    public var cardHolder: String {
        return self.name
    }
}
