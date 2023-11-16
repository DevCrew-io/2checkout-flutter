//
//  CardFactory.kt
//  com.twocheckout.twocheckout_flutter
//
//  Copyright © 2023 DevCrew I/O
//

package com.twocheckout.twocheckout_flutter.Model
import com.twocheckout.twocheckout_flutter.datapack.CreditCardInputResult
import com.twocheckout.twocheckout_flutter.datapack.PayerCardData

object CardFactory {
    fun createCardFromMap(arguments: Map<String, Any>): CreditCardInputResult {
        val cardInputObject = CreditCardInputResult()
        cardInputObject.name = arguments["name"] as? String ?: ""
        val cardPayData = PayerCardData()
        cardPayData.expirationDate = arguments["expirationDate"] as? String ?: ""
        cardPayData.creditCard = arguments["creditCard"] as? String ?: ""
        cardPayData.cvv = arguments["cvv"] as? String ?: ""
        cardInputObject.cardData = cardPayData
        return cardInputObject
    }
}
