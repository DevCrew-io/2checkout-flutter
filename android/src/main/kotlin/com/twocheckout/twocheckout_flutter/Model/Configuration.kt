//
//  Configuration.kt
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

package com.twocheckout.twocheckout_flutter.Model

object Configuration {
    var secretKey: String = ""
    var merchantCode: String = ""
    var channelName: String = "twocheckout_flutter"

    var price: Double = 0.0
    var currency: String = "USD"
    var local: String = "en"

    fun fromMap(arguments: Map<String, Any>) {
        this.secretKey = arguments["secretKey"] as? String ?: ""
        this.merchantCode = arguments["merchantCode"] as? String ?: ""
    }

    fun updatePaymentDetails(arguments: Map<String, Any>) {
        this.price = arguments["price"] as? Double ?: 0.0
        this.currency = arguments["currency"] as? String ?: "$"
        this.local = arguments["local"]  as? String ?: "en"
    }
}