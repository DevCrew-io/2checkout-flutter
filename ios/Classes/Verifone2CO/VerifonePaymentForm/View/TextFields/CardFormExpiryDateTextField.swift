//
//  CardFormExpiryDateTextField.swift
//  Verifone2CO
//

import UIKit

public class CardFormExpiryDateTextField: BaseTextField {

    // MARK: - Properties
    fileprivate var _delegate: UITextFieldDelegate?

    public override var delegate: UITextFieldDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
        }
    }

    public private(set) var getMonth: String?
    public private(set) var getYear: String?

    private(set) var selectedMonth: Int? {
        didSet {
            guard let selectedMonth = self.selectedMonth else {
                return
            }
            if !(Calendar.validExpirationMonthRange ~= selectedMonth) {
                self.selectedMonth = nil
            }
        }
    }

    private(set) var selectedYear: Int?

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
    }

    public override func validateAndThrowError() throws {
        try super.validateAndThrowError()

        guard let year = self.selectedYear, let month = self.selectedMonth else {
            throw VF2COValidationError.invalidData
        }

        let now = Date()
        let calendar = Calendar.creditCardInformationCalendar
        let thisMonth = calendar.component(.month, from: now)
        let thisYear = calendar.component(.year, from: now)

        if (year == thisYear && thisMonth > month) || thisYear > year {
            throw VF2COValidationError.invalidData
        }
    }
}

// MARK: - CardFormExpiryDateTextFieldDelegate

extension CardFormExpiryDateTextField: UITextFieldDelegate {
    override func textFieldDidChange() {
        formattedExpireDate(self)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }

    func formattedExpireDate(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let dividerString = "/"
        var str = text.replacingOccurrences(of: dividerString, with: "", options: .literal)
        let month = Int(str)

        if str.count == 1 && month != nil && month! > 1 {
          let formattedMonth = String(format: "%02d", month!)
          str = formattedMonth
        }

        if str.count >= 3 {
            let expiryMonth = str[Range(0...1)]
            var expiryYear: String
            if str.count == 3 {
                expiryYear = str[2]
            } else {
                expiryYear = str[Range(2...3)]
            }
            guard let expiryMonthDigits = Int(expiryMonth) else { return }
            guard let expiryYearDigits = Int(expiryYear) else { return }
            selectedMonth = expiryMonthDigits
            selectedYear = 2000 + expiryYearDigits
            getYear = expiryYear
            getMonth = expiryMonth
            textField.text = expiryMonth + dividerString + expiryYear
        } else {
            textField.text = str
        }
    }
}
