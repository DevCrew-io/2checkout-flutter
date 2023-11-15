//
//  Extensions.swift
//  Verifone2CO
//

import Foundation

extension Bundle {
    #if !SWIFT_PACKAGE
    static var module = Bundle(for: BaseFormViewController.self)
    #endif
}

extension Array where Element: BaseTextField {
    func areFieldsValid() -> Bool {
        return self.reduce(into: true, { (valid, field) in
            return valid = valid && field.isValid
        })
    }
}

extension CreditCardFormViewController {
    func updateInputViewWithFirstResponder(_ firstResponder: BaseTextField) {
        guard cardFormInputFields.contains(firstResponder) else { return }
        currentEditingTextField = firstResponder
        gotoPrevFieldBarButtonItem.isEnabled = firstResponder !== cardFormInputFields.first
        gotoNextFieldBarButtonItem.isEnabled = firstResponder !== cardFormInputFields.last
    }

    func gotoPrevField() {
        guard let currentTextField = currentEditingTextField, let index = cardFormInputFields.firstIndex(of: currentTextField) else {
            return
        }

        let prevIndex = index - 1
        guard prevIndex >= 0 else { return }
        cardFormInputFields[prevIndex].becomeFirstResponder()
    }

    func gotoNextField() {
        guard let currentTextField = currentEditingTextField, let index = cardFormInputFields.firstIndex(of: currentTextField) else {
            return
        }

        let nextIndex = index + 1
        guard nextIndex < cardFormInputFields.count else { return }
        cardFormInputFields[nextIndex].becomeFirstResponder()
    }

    func doneEditing() {
        view.endEditing(true)
    }
}
