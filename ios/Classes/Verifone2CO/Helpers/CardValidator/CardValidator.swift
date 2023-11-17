//
//  CardValidator.swift
//  CheckoutKit/CheckoutKit/CardValidator.swift
//
//  Created by Manon Henrioux on 19/08/2015.
//
//

import Foundation
// swiftlint:disable identifier_name
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

/**  Class containing verification methods about cards numbers, CVV, expiry dates, and useful constants about card types */

open class CardValidator {

    public struct CardInfo: Equatable {

        fileprivate static let DEFAULT_CARD_FORMAT: String = "(\\d{1,4})"

        public static let MAESTRO = CardInfo(name: "maestro", pattern: "^(5[0,6-8]|6304|6759|676[1-3])", format: DEFAULT_CARD_FORMAT, cardLength: 12...19, cvvLength: [3], luhn: true, supported: true)
        public static let MASTERCARD = CardInfo(name: "mastercard",
                                                pattern: "^(5[1-5]|2(2(2[1-9]|[3-9])|[3-6]|7(0|1|20)))",
                                                format: DEFAULT_CARD_FORMAT, cardLength: 16...17,
                                                cvvLength: [3], luhn: true, supported: true)
        public static let DINERSCLUB = CardInfo(name: "dinersclub",
                                                pattern: "^3(0[0-5]|[6,8-9])|^5[4-5]",
                                                format: "(\\d{1,4})(\\d{1,6})?(\\d{1,4})?",
                                                cardLength: 14...14,
                                                cvvLength: [3], luhn: true, supported: true)
        public static let LASER = CardInfo(name: "laser", pattern: "^(6304|670[69]|6771)", format: DEFAULT_CARD_FORMAT, cardLength: 16...19, cvvLength: [3], luhn: true, supported: false)
        public static let JCB = CardInfo(name: "jcb", pattern: "^35(2[89]|[3-8])", format: DEFAULT_CARD_FORMAT, cardLength: 16...16, cvvLength: [3], luhn: true, supported: true)
        public static let UNIONPAY = CardInfo(name: "unionpay", pattern: "^(62[0-9]{14,17})$", format: DEFAULT_CARD_FORMAT, cardLength: 16...19, cvvLength: [3], luhn: false, supported: false)
        public static let DISCOVER = CardInfo(name: "discover",
                                              pattern: "^(6011|622(12[6-9]|1[3-9][0-9]|[2-8][0-9]{2}|9[0-1][0-9]|92[0-5]|64[4-9])|65)",
                                              format: DEFAULT_CARD_FORMAT, cardLength: 16...16,
                                              cvvLength: [3], luhn: true, supported: true)
        public static let AMEX = CardInfo(name: "amex", pattern: "^3[47]", format: "^(\\d{1,4})(\\d{1,6})?(\\d{1,5})?$", cardLength: 15...15, cvvLength: [4], luhn: true, supported: true)
        public static let VISA = CardInfo(name: "visa", pattern: "^4", format: DEFAULT_CARD_FORMAT, cardLength: 13...16, cvvLength: [3], luhn: true, supported: true)

        public static let cards: [CardInfo] = [.MAESTRO, .MASTERCARD, .DINERSCLUB, .LASER, .JCB, .UNIONPAY, .DISCOVER, .AMEX, .VISA]

        public let name: String
        public let pattern: String
        public let format: String
        public let cardLength: ClosedRange<Int>
        public let cvvLength: [Int]
        public let luhn: Bool
        public let supported: Bool

        /**
        Default constructor
        
        @param name name of the card
        
        @param pattern regular expression matching the card's code
        
        @param format default card display format
        
        @param cardLength array containing all the possible lengths of the card's code
        
        @param cvvLength array containing all the possible lengths of the card's CVV
        
        @param luhn does the card's number respects the luhn validation or not
        
        @param supported is this card usable with Checkout services
        
        */
        fileprivate init(name: String, pattern: String, format: String, cardLength: ClosedRange<Int>, cvvLength: [Int], luhn: Bool, supported: Bool) {
            self.name = name
            self.pattern = pattern
            self.format = format
            self.cardLength = cardLength
            self.cvvLength = cvvLength
            self.luhn = luhn
            self.supported = supported
        }

        public func getName() -> String? {
            switch name {
            case "visa":
                return "Visa"
            case "mastercard":
                return "Mastercard"
            case "jcb":
                return "JCB"
            case "amex":
                return "AMEX"
            case "dinersclub":
                return "Diners"
            case "discover":
                return "Discover"
            case "laser":
                return "Laser"
            case "maestro":
                return "Maestro"
            default:
                return nil
            }
        }
    }

    /* Regular expression used for sanitizing the card's name */
    public static let CARD_NAME_REPLACE_PATTERN = "[^A-Z\\s]"

    /*
    
    Test if the string is composed exclusively of digits
    
    @param entry String to be tested
    
    @return result of the test
    
    */

    fileprivate class func isDigit(_ entry: String) -> Bool {
        return Regex(pattern: "^\\d+$").matches(entry)
    }

    /**
    
    Sanitizes any string given as a parameter
    
    @param entry String to be cleaned
    
    @param isNumber boolean, if set, the method removes all non digit characters, otherwise only the - and spaces
    
    @return cleaned string
    
    */

    open class func sanitizeEntry(_ entry: String, isNumber: Bool) -> String {
        let a: String = isNumber ? "\\D" : "\\s+|-"
        return Regex(pattern: a).replace(entry, template: "")
    }

    /*
    
    Sanitizes the card's name using the regular expression above
    
    @param entry String to be cleaned
    
    @return cleaned string
    
    */

    fileprivate class func sanitizeName(_ entry: String) -> String {
        return Regex(pattern: CARD_NAME_REPLACE_PATTERN).replace(entry.uppercased(), template: "")
    }

    /**
    
    Returns the CardInfo element corresponding to the given number
    
    @param number String containing the card's number
    
    @return CardInfo element corresponding to num or null if it was not recognized
    
    */

    open class func getCardType(_ number: String) -> CardInfo? {
        let n = sanitizeEntry(number, isNumber: true)
        return CardInfo.cards.first { brand -> Bool in
            n.range(of: brand.pattern, options: .regularExpression, range: nil, locale: nil) != nil
        }
    }

    /*
    
    Applies the Luhn Algorithm to the given card number
    
    @param number String containing the card's number to be tested
    
    @return boolean containing the result of the computation
    
    */

    fileprivate class func validateLuhnNumber(_ number: String) -> Bool {
        if number == "" { return false }
        var nCheck: Int = 0
        var nDigit: Int? = 0
        var even = false
        let n = sanitizeEntry(number, isNumber: true)
        let array = Array(n)
        for i in (0 ..< (array.count)).reversed() {
            nDigit = Int(String(array[i]))
            if nDigit == nil {
                return false
            }

            if even {
                nDigit = nDigit! * 2
                if nDigit > 9 { nDigit = nDigit! - 9 }
            }
            nCheck = nCheck + nDigit!
            even = !even
        }
        return (nCheck%10) == 0
    }

    /**
    
    Checks if the card's number is valid by identifying the card's type and checking its conditions
    
    @param number String containing the card's code to be verified
    
    @return boolean containing the result of the verification
    
    */

    open class func validateCardNumber(_ number: String) -> Bool {
        if number == "" { return false }
        let n = sanitizeEntry(number, isNumber: true)
        if Regex(pattern: "^\\d+$").matches(n) {
            let c = getCardType(n)
            if c != nil {
                var len = false
                for i in c!.cardLength where n.count == i {
                    len = true
                    break
                }
                return len && (c!.luhn == false || validateLuhnNumber(n))
            }
        }
        return false
    }

    /**
    
    Checks if the card is still valid
    
    @param month String containing the expiring month of the card
    
    @param year String containing the expiring year of the card
    
    @return boolean containing the result of the verification
    
    */

    open class func validateExpiryDate(_ month: String, year: String) -> Bool {
        if year.count != 2 && year.count != 4 { return false }
        let m: Int? = Int(month)
        let y: Int? = Int(year)
        if m != nil && y != nil {
            return validateExpiryDate(m!, year: y!)
        }
        return false
    }

    /**
    
    Checks if the card is still valid
    
    @param month int containing the expiring month of the card
    
    @param year int containing the expiring year of the card
    
    @return boolean containing the result of the verification
    
    */

    open class func validateExpiryDate(_ month: Int, year: Int) -> Bool {
        if month < 1 || year < 1 { return false }

        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month, .year], from: date)
        let curMonth = components.month
        var curYear = components.year
        if year < 100 { curYear = curYear! - 2000 }
        return (curYear! == year) ? curMonth! <= month : curYear! < year
    }

    /**
    
    Checks if the CVV is valid for a given card's type
    
    @param cvv String containing the value of the CVV
    
    @param card Cards element containing the card's type
    
    @return boolean containing the result of the verification
    
    */

    open class func validateCVV(_ cvv: String, card: CardInfo) -> Bool {
        if cvv == "" { return false }
        if card.cvvLength.contains(cvv.count) {
            return true
        }

        return false
    }

    /**
    
    Checks if the CVV is valid for a given card's type
    
    @param cvv int containing the value of the CVV
    
    @param card Cards element containing the card's type
    
    @return boolean containing the result of the verification
    
    */

    open class func validateCVV(_ cvv: Int, card: CardInfo) -> Bool {
        return validateCVV(String(cvv), card: card)
    }

}
