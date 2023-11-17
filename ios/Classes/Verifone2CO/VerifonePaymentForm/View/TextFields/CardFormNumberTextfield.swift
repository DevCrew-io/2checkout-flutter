//
//  CardFormNumberTextfield.swift
//  Verifone2CO
//
//  Created by Oraz Atakishiyev on 18.01.2023.
//

import UIKit

public enum SecureTextEtryType: String, CaseIterable {
    case none = "none"
    case partialHide = "partial hide"
    case hidden = "hidden"

    static func build(rawValue: String) -> SecureTextEtryType {
        return SecureTextEtryType(rawValue: rawValue) ?? .none
    }

    public static var asArray: [SecureTextEtryType] {return self.allCases}

    public func asInt() -> Int {
        return SecureTextEtryType.asArray.firstIndex(of: self)!
    }
}

public class CardFormNumberTextField: BaseTextField {
    
    // MARK: - Properties
    var actualText: String = ""
    var secureTextEntry: SecureTextEtryType = .none

    fileprivate var spaceCount: Int = 3
    fileprivate var maskedText: String = ""
    fileprivate var previousTextFieldContent: String?
    fileprivate var previousSelection: UITextRange?
    fileprivate var _delegate: UITextFieldDelegate?

    public var getNumbers: String? {
        get {
            return self.actualText.replacingOccurrences(of: " ", with: "", options: .literal)
        }
    }
    public var cardBrand: String? {
        return CardValidator.getCardType(actualText)?.getName()
    }

    public override var delegate: UITextFieldDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }

    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    override init() {
        super.init(frame: CGRect.zero)
        configure()
    }

    private func configure() {
        keyboardType = .numberPad
        super.delegate = self
        placeholder = placeholder
        textContentType = .creditCardNumber
    }

    public override func validateAndThrowError() throws {
        guard !self.actualText.isEmpty else {
            throw VF2COValidationError.requiredInput
        }
        if !CardValidator.validateCardNumber(self.actualText) {
            throw VF2COValidationError.invalidData
        }
    }

    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }

    public override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
}

extension CardFormNumberTextField: UITextFieldDelegate {
    override func textFieldDidChange() {
        if secureTextEntry == .partialHide {
            let card = CardValidator.getCardType(self.actualText)
            let cardLength: Int = card?.cardLength.upperBound ?? 16

            let cardNumberSpace: String = " "
            let cardLengthWithSpaces: Int = (cardLength + spaceCount)
            let cardObscureLength: Int = (cardLength - 4)

            var value = String()
            let length = actualText.count
            // swiftlint: disable unused_enumerated
            for (i, _) in actualText.enumerated() {

                if (length <= cardObscureLength) {
                    if (i == (length - 1)) {
                        let charIndex = actualText.index(actualText.startIndex, offsetBy: i)
                        let tempStr = String(actualText.suffix(from: charIndex))
                        value = value + tempStr
                    } else {
                        value = value + "●"
                    }
                } else {
                    if (i < cardObscureLength) {
                        value = value + "●"
                    } else {
                        let charIndex = actualText.index(actualText.startIndex, offsetBy: i)
                        let tempStr = String(actualText.suffix(from: charIndex))
                        value = value + tempStr
                        break
                    }
                }

                if (((i + 1) % 4 == 0) && (value.count < cardLengthWithSpaces)) {
                    value = value + cardNumberSpace
                }
            }
            self.text = value
        } else if secureTextEntry == .hidden {
            self.isSecureTextEntry = true
            self.text = actualText
            self.spaceCount = 0
        } else {
            self.text = insertSpaces(actualText)
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        previousTextFieldContent = textField.text
        previousSelection = textField.selectedTextRange

        let textRange = Range(range, in: textField.text!)!
        let updatedText = textField.text!.replacingCharacters(in: textRange, with: string)

        let card = CardValidator.getCardType(self.actualText)
        if !actualText.isNumber {
            actualText.remove(at: actualText.index(before: actualText.endIndex))
            self.text!.remove(at: self.text!.index(before: self.text!.endIndex))
            return false
        }

        if (!string.isEmpty) {
            if card != nil && textField.text!.count >= card!.cardLength.upperBound + spaceCount {
                textField.text = previousTextFieldContent
                textField.selectedTextRange = previousSelection
                return false
            } else if card == nil && textField.text!.count >= 16 {
                return false
            }
            self.actualText = String(format: "%@%@", self.actualText, string)
        } else {
            if self.actualText.count > 1 && range.upperBound - range.lowerBound > 1 && range.lowerBound != 0 {
                if secureTextEntry == .partialHide {
                    let cnumber = updatedText.replacingOccurrences(of: " ", with: "")
                    self.actualText = String(actualText[cnumber.startIndex..<cnumber.endIndex]).replacingOccurrences(of: " ", with: "")
                } else {
                    self.actualText = updatedText.replacingOccurrences(of: " ", with: "")
                }
            } else if (self.actualText.count > 1 && (range.upperBound-range.lowerBound) == 1) {
                let length = self.actualText.count-1
                self.actualText = String(self.actualText[
                    self.actualText
                        .index(self.actualText.startIndex, offsetBy: 0)...self.actualText
                        .index(self.actualText.startIndex, offsetBy: length-1)])
            } else {
                self.actualText = ""
            }
        }
        return true
    }

    public func insertSpaces(_ string: String) -> String {
        var stringWithAddedSpaces = ""
        for i in 0..<string.count {
            if ((i > 0) && ((i % 4) == 0)) {
                stringWithAddedSpaces += " "
            }
            stringWithAddedSpaces.append(string[string.index(string.startIndex, offsetBy: i)])
        }
        return stringWithAddedSpaces
    }
}

extension String {
    var isNumber: Bool {
        return self.range(
            of: "^[0-9]*$",
            options: .regularExpression) != nil
    }
}
