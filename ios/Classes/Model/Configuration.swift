//
//  Configuration.swift
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

import Foundation

final class Configuration {
    public static let shared = Configuration()

    var secretKey: String
    var merchantCode: String
    var channelName: String
    
    var price: Double
    var currency: String
    var local: String

    private init() {
        self.secretKey = ""
        self.merchantCode = ""
        self.channelName = "twocheckout_flutter"
        
        self.price = 0
        self.currency = "USD"
        self.local = "en"
    }

    func fromMap(_ arguments: [String: Any]) {
        self.secretKey = arguments["secretKey"] as? String ?? ""
        self.merchantCode = arguments["merchantCode"] as? String ?? ""
    }
    
    func updatePaymentDetails(_ arguments: [String: Any]) {
        self.price = arguments["price"] as? Double ?? 0
        self.currency = arguments["currency"] as? String ?? "$"
        self.local = arguments["local"] as? String ?? "en"
    }
}
