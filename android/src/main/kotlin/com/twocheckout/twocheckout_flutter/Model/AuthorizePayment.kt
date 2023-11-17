//
//  AuthorizePayment.kt
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

package com.twocheckout.twocheckout_flutter.Model

object AuthorizePayment {
    var url: String = ""
    var parameters: Map<String, Any> = mapOf()
    var successReturnUrl: String = ""
    var cancelReturnUrl: String = ""

    fun fromMap(arguments: Map<String, Any>) {
        this.url = arguments["url"] as? String ?: ""
        this.parameters = arguments["parameters"] as? Map<String, Any> ?: mapOf()
        this.successReturnUrl = arguments["successReturnUrl"] as? String ?: ""
        this.cancelReturnUrl = arguments["cancelReturnUrl"] as? String ?: ""
    }
}