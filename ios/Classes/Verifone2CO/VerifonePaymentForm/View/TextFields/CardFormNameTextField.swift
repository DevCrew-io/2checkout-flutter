//
//  CardFormNameTextField.swift
//  Verifone2CO
//

import UIKit

public class CardFormNameTextField: BaseTextField {

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
        keyboardType = .default
        textContentType = .name
    }

    public override func validateAndThrowError() throws {
        try super.validateAndThrowError()
        guard let text = self.text else {
            throw VF2COValidationError.requiredInput
        }
        let validCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ")
        if text.count < 3 {
            throw VF2COValidationError.invalidData
        } else if text.rangeOfCharacter(from: validCharacters.inverted) != nil {
            throw VF2COValidationError.invalidData
        }
    }
}
