//
//  CardFactory.swift
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

import Foundation

final class CardFactory {
    private init() {}

    static func createCardFromMap(_ arguments: [String: Any]) -> Card {
        return Card(name: arguments["name"] as? String ?? "",
                    creditCard: arguments["creditCard"] as? String ?? "",
                    cvv: arguments["cvv"] as? String ?? "",
                    expirationDate: arguments["expirationDate"] as? String ?? "",
                    scope: arguments["scope"] as? String)
    }
}
