//
//  Calendar+Extension.swift
//  Verifone2CO
//

import Foundation

extension Calendar {
    public static let creditCardInformationCalendar = Calendar(identifier: .gregorian)
    public static let validExpirationMonthRange: Range<Int> = Calendar.creditCardInformationCalendar.maximumRange(of: .month)!
}
