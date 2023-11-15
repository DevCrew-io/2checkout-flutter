//
//  FormButton.swift
//  Verifone2CO
//

import UIKit

public class FormButton: UIButton {

    // MARK: - PROPERTIES
    private var backgroundColors: [ControlState: UIColor] = [:]

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable public var defaultBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(defaultBackgroundColor, for: .normal)
        }
    }

    @IBInspectable public var disabledBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(disabledBackgroundColor, for: .disabled)
        }
    }

    public override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }

    public override var backgroundColor: UIColor? {
        get {
            return backgroundColors[state] ?? backgroundColors[.normal] ?? self.defaultBackgroundColor
        }
        set {
            defaultBackgroundColor = newValue
            updateBackgroundColor()
        }
    }

    // MARK: - INITIALIZERS
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateBackgroundColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateBackgroundColor()
    }

    func setBackgroundColor(_ color: UIColor?, for state: ControlState) {
        backgroundColors[state] = color
        updateBackgroundColor()
    }

    private func updateBackgroundColor() {
        super.backgroundColor = self.backgroundColor
    }

    func backgroundColor(for state: ControlState) -> UIColor? {
        return backgroundColors[state]
    }
}
