//
//  CardFormCVVTextField.swift
//  Verifone2CO
//
//  Created by Oraz Atakishiyev on 18.01.2023.
//

import UIKit

public class CVVTextField: BaseTextField {

    // MARK: - Properties
    var secureTextEntry: SecureTextEtryType = .none {
        didSet {
            self.isSecureTextEntry = secureTextEntry == .none ? false : true
        }
    }
    private let validLengths = 3...4

    @available(iOS, unavailable)
    public override var delegate: UITextFieldDelegate? {
        get {
            return self
        }
        set {}
    }

    public override var keyboardType: UIKeyboardType {
        didSet {
            super.keyboardType = .numberPad
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

    public override init() {
        super.init(frame: CGRect.zero)
        configure()
    }

    private func configure() {
        super.keyboardType = .numberPad
        super.delegate = self
    }

    public override func validateAndThrowError() throws {
        try super.validateAndThrowError()

        guard let text = self.text else {
            throw VF2COValidationError.requiredInput
        }
        if !(validLengths ~= text.count) {
            throw VF2COValidationError.invalidData
        }
    }
}

extension CVVTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }

        guard range.length >= 0 else {
            return true
        }
        let maxLength = 4

        return maxLength >= (self.text?.count ?? 0) - range.length + string.count
    }
}
