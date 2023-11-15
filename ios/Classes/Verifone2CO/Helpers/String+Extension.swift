//
//  String+Extension.swift
//  Verifone2CO
//

import Foundation

extension String {
    subscript(range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[startIndex..<endIndex])
    }

    subscript(index: Int) -> String {
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return String(self[charIndex])
    }

    func localized(withComment comment: String = "") -> String {
        return Verifone2CO.getBundle().localizedString(forKey: self,
                                                            value: "**\(self)**",
                                                            table: nil)
    }
}
