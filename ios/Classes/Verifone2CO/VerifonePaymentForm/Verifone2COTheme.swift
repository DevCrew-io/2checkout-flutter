//
//  Verifone2COTheme.swift
//  Verifone2CO
//

import UIKit

extension Verifone2CO {
    public class Theme {
        public static let defaultTheme = Theme()

        public var primaryBackgorundColor: UIColor = VerifoneThemeDefaultPrimaryBackgroundColor
        public var textfieldBackgroundColor: UIColor = VerifoneThemeDefaultTextfieldBackgroundColor
        public var textfieldTextColor: UIColor = VerifoneThemeDefaultTextfieldTextColor
        public var textfieldBorderColor: UIColor = VerifoneThemeDefaultTextfieldBorderColor
        public var payButtonBackgroundColor: UIColor = VerifoneThemeDefaultPayButtonBackgroundColor
        public var payButtonDisabledBackgroundColor: UIColor = VerifoneThemeDefaultPayButtonDisabledBackgroundColor
        public var payButtonTextColor: UIColor = VerifoneThemeDefaultPayButtonTextColor
        public var labelColor: UIColor = VerifoneThemeDefaultLabelColor
        public var cardTitleColor: UIColor = VerifoneThemeDefaultCardTitleColor

        public var font: UIFont {
            get {
                if let _font = _font {
                    return _font
                } else {
                    let fontMetrics = UIFontMetrics(forTextStyle: .body)
                    return fontMetrics.scaledFont(for: VerifoneDefaultFont)
                }
            }
            set {
                _font = newValue
            }
        }
        private var _font: UIFont?

        // MARK: Default Font
        private let VerifoneDefaultFont = UIFont.systemFont(ofSize: 17)
    }
}

private var VerifoneThemeDefaultPrimaryBackgroundColor: UIColor {
    return UIColor.VF2Co.background
}

private var VerifoneThemeDefaultTextfieldBackgroundColor: UIColor {
    return UIColor.VF2Co.background
}

// TextField text color
private var VerifoneThemeDefaultTextfieldTextColor: UIColor {
    return UIColor.VF2Co.defaultBlackLabelColor
}

// TextField border color
private var VerifoneThemeDefaultTextfieldBorderColor: UIColor {
    return UIColor.VF2Co.cardFormTextfieldBorder
}

// Pay button enabled background color
private var VerifoneThemeDefaultPayButtonBackgroundColor: UIColor {
    return  UIColor.VF2Co.cardFormButton
}

// Pay button disabled background color
private var VerifoneThemeDefaultPayButtonDisabledBackgroundColor: UIColor {
    return  UIColor.VF2Co.secondaryLabel
}

// Pay button text color
private var VerifoneThemeDefaultPayButtonTextColor: UIColor {
    return  UIColor.white
}

// Card form default label color
private var VerifoneThemeDefaultLabelColor: UIColor {
    return UIColor.VF2Co.defaultBlackLabelColor
}

// Card form title text color
private var VerifoneThemeDefaultCardTitleColor: UIColor {
    return UIColor.VF2Co.defaultBlackLabelColor
}
