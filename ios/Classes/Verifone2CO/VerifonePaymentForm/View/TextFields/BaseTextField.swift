//
//  BaseTextField.swift
//  Verifone2CO
//

import UIKit

enum VF2COValidationError: Error {
    case requiredInput
    case invalidData
}

public class BaseTextField: UITextField {
    // MARK: - Properties
    private var normalTextColor: UIColor?

    var padding: UIEdgeInsets!
    var borderWidth: CGFloat = 0.0

    public override var placeholder: String? {
        didSet {
            updatePlaceholderTextColor()
        }
    }

    var placeholderTextColor: UIColor? {
        didSet {
            updatePlaceholderTextColor()
        }
    }

    var errorHintColor: UIColor? {
        didSet {
            updateTextColor()
        }
    }

    var borderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            updateBorder()
        }
    }

    public override var text: String? {
        didSet {
            updateTextColor()
        }
    }

    public override var textColor: UIColor? {
        get {
            return normalTextColor
        }
        set {
            normalTextColor = newValue
            updateTextColor()
        }
    }

    public var isValid: Bool {
        do {
            try validateAndThrowError()
            return true
        } catch {
            return false
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

    init() {
        super.init(frame: CGRect.zero)
        configure()
    }

    private func configure() {
        padding = UIEdgeInsets(
            top: layoutMargins.top,
            left: layoutMargins.left,
            bottom: layoutMargins.bottom,
            right: layoutMargins.right
        )
        addTarget(self,
                  action: #selector(self.textFieldDidChange),
                  for: UIControl.Event.editingChanged)
        addTarget(self,
                  action: #selector(self.textFieldEditingDidBegin),
                  for: UIControl.Event.editingDidBegin)
        addTarget(self,
                  action: #selector(self.textFieldEditingDidEnd),
                  for: UIControl.Event.editingDidEnd)
    }
}

extension BaseTextField {
    @objc func textFieldDidChange() { }
    @objc func textFieldEditingDidBegin() { }
    @objc func textFieldEditingDidEnd() { }

    // Override the textRect method to return the bounds with the added padding
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    // Override the placeholderRect method to return the bounds with the added padding
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    // Override the editingRect method to return the bounds with the added padding
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    // Adding padding to right view
    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    // Adding padding to left view
    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.leftViewRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    func textAreaViewRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    // Update the text color based on the validation of the text field's input
    private func updateTextColor() {
        guard errorHintColor != nil else {
            super.textColor = normalTextColor ?? .black
            return
        }
        super.textColor = isValid || isFirstResponder ? (normalTextColor ?? .black) : errorHintColor
    }

    // Update the placeholder text color
    func updatePlaceholderTextColor() {
        if let attributedPlaceholder = attributedPlaceholder, let placeholderColor = placeholderTextColor {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedPlaceholder)

            let formattingPlaceholderString = formattingAttributedText.string
            let range = NSRange(formattingPlaceholderString.startIndex..<formattingPlaceholderString.endIndex,
                                in: formattingPlaceholderString)
            formattingAttributedText.addAttribute(.foregroundColor, value: placeholderColor, range: range)
            self.attributedPlaceholder = formattingAttributedText.copy() as? NSAttributedString
        }
    }

    @objc public func validateAndThrowError() throws {
        guard let text = text else {
            throw VF2COValidationError.requiredInput
        }
        if text.isEmpty {
            throw VF2COValidationError.requiredInput
        }
    }

    private func updateBorder() {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor?.cgColor
    }
}
