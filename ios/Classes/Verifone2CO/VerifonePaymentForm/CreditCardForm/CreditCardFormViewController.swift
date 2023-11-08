//
//  CreditCardForm.swift
//  Verifone2CO
//
//  Created by Oraz Atakishiyev on 17.01.2023.
//

import UIKit

public final class CreditCardFormViewController: Verifone2COPaymentForm {

    // MARK: - PROPERTIES
    private var theme: Verifone2CO.Theme!
    var onPayPressed: ((Card, _ isCardSaveOn: Bool) -> Void)?
    public var didSaveCardStateChanged: ((_ isOn: Bool) -> Void)?
    public var currentEditingTextField: BaseTextField?
    private var contentView: UIScrollView! = UIScrollView()
    private var titleCardForm: UILabel = UILabel(frame: .zero)
    private var closeButton: UIButton = UIButton(frame: .zero)
    private var verifoneLogo: UIImageView = UIImageView(image: UIImage(named: "logo", in: .module, compatibleWith: nil))
    private var lockImage: UIImageView = UIImageView(image: UIImage(named: "lock", in: .module, compatibleWith: nil))
    private var footerText: UILabel = UILabel(frame: .zero)

    private var cardFormNumberLabel: UILabel = UILabel(frame: .zero)
    private var cardFormExpiryDateLabel: UILabel = UILabel(frame: .zero)
    private var cardFormCvcLabel: UILabel = UILabel(frame: .zero)
    private var cardFormNameLabel: UILabel = UILabel(frame: .zero)
    private var switchButtonLabel: UILabel = UILabel(frame: .zero)

    private var cardFormNumberTextField: CardFormNumberTextField = CardFormNumberTextField(frame: .zero)
    private var cardFormExpiryDateTextField: CardFormExpiryDateTextField = CardFormExpiryDateTextField(frame: .zero)
    private var cardFormCvcTextField: CVVTextField = CVVTextField(frame: .zero)
    private var cardFormNameTextField: CardFormNameTextField = CardFormNameTextField(frame: .zero)
    private var switchButton: UISwitch = UISwitch(frame: .zero)
    private var hBottomStackView: UIStackView   = UIStackView()

    private var cardFormNumberErrorLabel: UILabel = UILabel(frame: .zero)
    private var cardFormExpiryDateErrorLabel: UILabel = UILabel(frame: .zero)
    private var cardFormCVCErrorLabel: UILabel = UILabel(frame: .zero)
    private var cardFormNameErrorLabel: UILabel = UILabel(frame: .zero)

    var gotoPrevFieldBarButtonItem: UIBarButtonItem! = UIBarButtonItem()
    var gotoNextFieldBarButtonItem: UIBarButtonItem! = UIBarButtonItem()
    var doneEditingBarButtonItem: UIBarButtonItem! = UIBarButtonItem()
    private var cardBrandImageView: UIImageView! = UIImageView()
    private var cvcInfoImageView: UIImageView! = UIImageView()
    private var edgeInsets = UIEdgeInsets(top: 0, left: 15.0, bottom: 0.0, right: -15.0)
    private var confirmButton: FormButton = FormButton(frame: .zero)

    var cardFormInputFields: [BaseTextField]! = []
    private var cardFormLabels: [UILabel]! = []
    private var cardFormErrorLabels: [UILabel]! = []
    private var fontName: String = "Helvetica Neue"

    private var formFieldsToolbarView: UIToolbar = UIToolbar()

    // MARK: - INITIALIZERS
    init(paymentConfiguration: Verifone2CO.PaymentConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.theme = paymentConfiguration.theme
        self.paymentConfiguration = paymentConfiguration
        self.cardFormNumberTextField.secureTextEntry = paymentConfiguration.cardSecureEntryType
        self.cardFormCvcTextField.secureTextEntry = paymentConfiguration.cardSecureEntryType
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureEventHandlers()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardFormNumberTextField.becomeFirstResponder()
    }

    public override func loadView() {
        super.loadView()
        guard isViewLoaded else {
            return
        }
        configureViews()
        configureColors()
        configureToolbar()
    }

    private func configureToolbar() {
        formFieldsToolbarView.barStyle = .default
        formFieldsToolbarView.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CreditCardFormViewController.doneEditing(_:)))
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)

        gotoPrevFieldBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "back", in: .module, compatibleWith: nil)!,
            style: UIBarButtonItem.Style.plain, target: self,
            action: #selector(CreditCardFormViewController.gotoPreviousField(_:)))
        gotoNextFieldBarButtonItem.width = 50.0
        gotoNextFieldBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "next_field", in: .module, compatibleWith: nil)!,
            style: UIBarButtonItem.Style.plain, target: self,
            action: #selector(CreditCardFormViewController.gotoNextField(_:)))

        formFieldsToolbarView.setItems([fixedSpaceButton, gotoPrevFieldBarButtonItem, fixedSpaceButton, gotoNextFieldBarButtonItem, flexibleSpaceButton, doneButton], animated: false)
    }

    private var isCardInputDataValid: Bool {
        return cardFormInputFields.areFieldsValid()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter().removeObserver(self, name: KeyboardWillShowFrameNotification, object: nil)
    }

    @discardableResult
    public override class func present(with configuration: Verifone2CO.PaymentConfiguration, from: UIViewController) -> Verifone2COPaymentForm {
        let controller = CreditCardFormViewController(paymentConfiguration: configuration)
        controller.presentPan(from: from)
        return controller
    }

    private func configureEventHandlers() {
        closeButton.addTarget(self, action: #selector(cancelForm), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(payAction), for: .touchUpInside)
        switchButton.addTarget(self, action: #selector(CreditCardFormViewController.saveCardSwitchChanged), for: .valueChanged)

        cardFormInputFields.forEach {
            $0.addTarget(self, action: #selector(updateCardBrand), for: .valueChanged)
            $0.addTarget(self, action: #selector(updateCardBrand), for: .editingChanged)
            $0.addTarget(self, action: #selector(updateTextFieldVlidationLabel(_:)), for: .editingDidBegin)
            $0.addTarget(self, action: #selector(validateTextField(_:)), for: .editingDidEnd)
        }
    }

    private func configureColors() {
        view.backgroundColor = theme.payButtonBackgroundColor

        confirmButton.setTitleColor(theme.payButtonTextColor, for: .normal)
        confirmButton.defaultBackgroundColor = theme.payButtonBackgroundColor
        confirmButton.disabledBackgroundColor = theme.payButtonDisabledBackgroundColor
        formFieldsToolbarView.barTintColor = UIColor.VF2Co.background

        self.view.backgroundColor = theme.primaryBackgorundColor
        cardFormInputFields = [cardFormNumberTextField,
                               cardFormExpiryDateTextField,
                               cardFormCvcTextField,
                               cardFormNameTextField]
        cardFormLabels = [cardFormNumberLabel,
                          cardFormExpiryDateLabel,
                          cardFormCvcLabel,
                          cardFormNameLabel]
        cardFormErrorLabels = [cardFormNumberErrorLabel,
                               cardFormExpiryDateErrorLabel,
                               cardFormCVCErrorLabel,
                               cardFormNameErrorLabel]

        cardFormInputFields.forEach {
            $0.inputAccessoryView = formFieldsToolbarView
        }

        cardFormErrorLabels.forEach {
            $0.textColor = UIColor.red
        }

        cardFormInputFields.forEach {
            $0.backgroundColor = theme.textfieldBackgroundColor
            $0.borderWidth = 1
            $0.cornerRadius = 3
            $0.textColor = theme.textfieldTextColor
            $0.borderColor = theme.textfieldBorderColor
            $0.placeholderTextColor = UIColor.VF2Co.cardFormTextfieldPlaceholder
        }

        cardFormLabels.forEach {
            $0.textColor = theme.labelColor
        }

        switchButtonLabel.textColor = theme.labelColor
        titleCardForm.textColor = theme.cardTitleColor

        updateCardBrand()
        cardFormNumberTextField.rightView = cardBrandImageView
        cardFormCvcTextField.rightView = cvcInfoImageView
    }

    @objc private func updateCardBrand() {
        confirmButton.isEnabled = isCardInputDataValid

        let cardBrandIconName: String? = cardFormNumberTextField.cardBrand
        var cvcInfoIconName: String?
        if cardFormNumberTextField.cardBrand == "AMEX" {
            cvcInfoIconName = "cvv_amex"
        } else if cardFormNumberTextField.cardBrand != nil {
            cvcInfoIconName = "cvv"
        }

        cardBrandImageView.image = cardBrandIconName.flatMap { UIImage(named: $0, in: .module, compatibleWith: nil) }
        cvcInfoImageView.image = cvcInfoIconName.flatMap { UIImage(named: $0, in: .module, compatibleWith: nil)}
        cardFormNumberTextField.rightViewMode = cardBrandImageView.image != nil ? .always : .never
        cardFormCvcTextField.rightViewMode = cvcInfoImageView.image != nil ? .always : .never
    }

    @objc private func validateTextFieldAndCatchError(_ textField: BaseTextField) {
        guard let errorLabel = setCardFormInputError(textField) else {
            return
        }
        do {
            try textField.validateAndThrowError()
            errorLabel.alpha = 0.0
        } catch {
            errorLabel.text = getValidationErrorString(for: textField, error: error)
            errorLabel.alpha = errorLabel.text != "" ? 1.0 : 0.0
        }
    }

    private func setCardFormInputError(_ textField: BaseTextField) -> UILabel? {
        switch textField {
        case cardFormNumberTextField:
            return cardFormNumberErrorLabel
        case cardFormExpiryDateTextField:
            return cardFormExpiryDateErrorLabel
        case cardFormCvcTextField:
            return cardFormCVCErrorLabel
        case cardFormNameTextField:
            return cardFormNameErrorLabel
        default:
            return nil
        }
    }

    @objc func payAction() {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let card = Card(
                name: self.cardFormNameTextField.text!,
                creditCard: self.cardFormNumberTextField.getNumbers!,
                cvv: self.cardFormCvcTextField.text!,
                expirationDate: "\(self.cardFormExpiryDateTextField.getMonth!)/\(self.cardFormExpiryDateTextField.getYear!)",
                scope: nil)
            self.onPayPressed?(card, self.switchButton.isOn)
        }
    }

    @objc func cancelForm() {
        let parent = self.presentingViewController
        self.dismiss(animated: true) {
            if let parent = parent {
                Verifone2COPaymentForm.present(with: self.paymentConfiguration, from: parent)
            }
        }
    }

    public override var panScrollable: UIScrollView? {
        return nil
    }

    public override func panModalWillDismiss() {
        cancelForm()
    }

    public override var allowsDragToDismiss: Bool {
        return true
    }

    public override var longFormHeight: PanModalHeight {
        return .maxHeight
    }

    public override var anchorModalToLongForm: Bool {
        return true
    }

    public override func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        true
    }

    public override var transitionDuration: Double {
        return 0.3
    }

    public override var springDamping: CGFloat {
        return 0.8
    }

    @objc internal override func onKeyboardWillShow(_ notification: Notification) {
        super.onKeyboardWillShow(notification)
        let intersectedFrame = contentView.convert(self.keyboardFrame!, from: nil)
        contentView.contentInset.bottom = intersectedFrame.height

        let bottomScrollIndicatorInset: CGFloat = intersectedFrame.height
        contentView.contentInset.bottom = bottomScrollIndicatorInset
        contentView.scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
    }

    @objc override func onKeyboardWillChangeFrame(_ notification: Notification) {
        guard let activeTextField = currentEditingTextField, let keyboardHeight = self.keyboardFrame?.height else {
            return
        }

        let bottomScrollIndicatorInset: CGFloat = keyboardHeight + activeTextField.frame.height
        contentView.contentInset.bottom = bottomScrollIndicatorInset
        contentView.scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
    }

    @objc internal override func onKeyboardWillHide(_ notification: Notification) {
        super.onKeyboardWillHide(notification)
        contentView.contentInset.bottom = 0.0
        contentView.scrollIndicatorInsets.bottom = 0.0
    }
}

extension CreditCardFormViewController {
    @objc private func saveCardSwitchChanged() {
        didSaveCardStateChanged?(switchButton.isOn)
    }

    private func getValidationErrorString(for textField: UITextField, error: Error) -> String {
        switch (error, textField) {
        case (VF2COValidationError.requiredInput, _):
            return ""
        case (VF2COValidationError.invalidData, cardFormNumberTextField):
            return "nrNotValid".localized(withComment: "Credit card number is invalid")
        case (VF2COValidationError.invalidData, cardFormExpiryDateTextField):
            return "cardExpiryDateFormat".localized(withComment: "Card expiry date is invalid")
        case (VF2COValidationError.invalidData, cardFormCvcTextField):
            return "cvvNotValid".localized(withComment: "CVV code is invalid")
        case (VF2COValidationError.invalidData, cardFormNameTextField):
            return "cardHolderNameInvalid".localized(withComment: "Card holder name is invalid")
        default:
            return ""
        }
    }
}

extension CreditCardFormViewController {

    @objc private func validateTextField(_ sender: BaseTextField) {
        let duration = TimeInterval(UINavigationController.hideShowBarDuration)
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseInOut, .allowUserInteraction]) {
            self.validateTextFieldAndCatchError(sender)
        }
        sender.borderColor = theme.textfieldBorderColor
    }

    @objc private func updateTextFieldVlidationLabel(_ sender: BaseTextField) {
        if let errorLabel = setCardFormInputError(sender) {
            let duration = TimeInterval(UINavigationController.hideShowBarDuration)
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: [.curveEaseInOut, .allowUserInteraction]) {
                errorLabel.alpha = 0.0
            }
        }

        sender.borderColor = view.tintColor
        updateInputViewWithFirstResponder(sender)
    }

    @objc private func gotoPreviousField(_ button: UIBarButtonItem) {
        gotoPrevField()
    }

    @objc private func gotoNextField(_ button: UIBarButtonItem) {
        gotoNextField()
    }

    @objc private func doneEditing(_ button: UIBarButtonItem?) {
        doneEditing()
    }
}

// MARK: - Configure constraints
extension CreditCardFormViewController {
    // swiftlint: disable function_body_length
    private func configureViews() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(contentView)

        self.contentView.addSubview(cardBrandImageView)

        self.contentView.addSubview(titleCardForm)
        self.contentView.addSubview(closeButton)

        self.contentView.addSubview(cardFormNumberLabel)
        self.contentView.addSubview(cardFormExpiryDateLabel)
        self.contentView.addSubview(cardFormCvcLabel)
        self.contentView.addSubview(cardFormNameLabel)

        self.contentView.addSubview(cardFormNumberTextField)
        self.contentView.addSubview(cardFormExpiryDateTextField)
        self.contentView.addSubview(cardFormCvcTextField)
        self.contentView.addSubview(cardFormNameTextField)

        self.contentView.addSubview(cardFormNumberErrorLabel)
        self.contentView.addSubview(cardFormExpiryDateErrorLabel)
        self.contentView.addSubview(cardFormCVCErrorLabel)
        self.contentView.addSubview(cardFormNameErrorLabel)

        titleCardForm.text = "cardTitle".localized()
        closeButton.tintColor = UIColor.VF2Co.cardFormLabel
        closeButton.setImage(UIImage(named: "close", in: .module, compatibleWith: nil), for: .normal)
        verifoneLogo.contentMode = UIView.ContentMode.scaleAspectFit
        lockImage.contentMode = UIView.ContentMode.scaleAspectFit

        footerText.text = "footerText".localized()
        footerText.textColor = UIColor.VF2Co.cardFormLabel

        cardFormNumberLabel.text = "cardNumberLabel".localized()
        cardFormExpiryDateLabel.text = "cardExpiryLabel".localized()
        cardFormCvcLabel.text = "cvvLabel".localized()
        cardFormNameLabel.text = "customerText".localized()

        switchButtonLabel.text = "switchButtonText".localized(withComment: "Save details for next time")

        confirmButton.setTitle("\("submitPay".localized()) \(!self.paymentConfiguration.totalAmount.isEmpty ? "\(self.paymentConfiguration.totalAmount)" : "")", for: .normal)
        confirmButton.cornerRadius = 3
        cardFormExpiryDateTextField.placeholder = "expiryPlaceholder".localized()

        // LABEL COLOR
        cardFormNumberLabel.textColor = UIColor.VF2Co.cardFormLabel
        cardFormExpiryDateLabel.textColor = UIColor.VF2Co.cardFormLabel
        cardFormCvcLabel.textColor = UIColor.VF2Co.cardFormLabel
        cardFormNameLabel.textColor = UIColor.VF2Co.cardFormLabel
        switchButtonLabel.textColor = UIColor.VF2Co.cardFormLabel

        // SET FONT
        cardFormNumberLabel.font = UIFont(name: fontName, size: 15)
        cardFormExpiryDateLabel.font = UIFont(name: fontName, size: 15)
        cardFormCvcLabel.font = UIFont(name: fontName, size: 15)
        cardFormNameLabel.font = UIFont(name: fontName, size: 15)
        footerText.font = UIFont(name: fontName, size: 10)

        switchButtonLabel.font = UIFont(name: fontName, size: 16)
        titleCardForm.font = UIFont(name: fontName, size: 17.0)
        confirmButton.titleLabel?.font = UIFont(name: fontName, size: 17)

        cardFormNumberTextField.font = UIFont(name: fontName, size: 13)
        cardFormExpiryDateTextField.font = UIFont(name: fontName, size: 13)
        cardFormCvcTextField.font = UIFont(name: fontName, size: 13)
        cardFormNameTextField.font = UIFont(name: fontName, size: 13)

        cardFormNumberErrorLabel.font = UIFont(name: fontName, size: 11)
        cardFormExpiryDateErrorLabel.font = UIFont(name: fontName, size: 11)
        cardFormCVCErrorLabel.font = UIFont(name: fontName, size: 11)
        cardFormNameErrorLabel.font = UIFont(name: fontName, size: 11)

        cardFormNumberTextField.textContentType = UITextContentType.creditCardNumber
        cardFormExpiryDateTextField.autocapitalizationType = UITextAutocapitalizationType.none
        cardFormExpiryDateTextField.keyboardType = UIKeyboardType.numberPad
        cardFormCvcTextField.autocapitalizationType = UITextAutocapitalizationType.none
        cardFormNameTextField.textContentType = .name
        cardFormNameTextField.autocapitalizationType = UITextAutocapitalizationType.none

        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleCardForm.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        verifoneLogo.translatesAutoresizingMaskIntoConstraints = false
        footerText.translatesAutoresizingMaskIntoConstraints = false

        cardFormNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardFormExpiryDateLabel.translatesAutoresizingMaskIntoConstraints = false
        cardFormCvcLabel.translatesAutoresizingMaskIntoConstraints = false
        cardFormNameLabel.translatesAutoresizingMaskIntoConstraints = false

        cardFormNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        cardFormExpiryDateTextField.translatesAutoresizingMaskIntoConstraints = false
        cardFormCvcTextField.translatesAutoresizingMaskIntoConstraints = false
        cardFormNameTextField.translatesAutoresizingMaskIntoConstraints = false

        cardFormNumberErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        cardFormExpiryDateErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        cardFormCVCErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        cardFormNameErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.backgroundColor = UIColor.VF2Co.cardFormButton

        // HTOPStack View for title and close button
        let hTopStackView   = UIStackView()
        hTopStackView.axis  = NSLayoutConstraint.Axis.horizontal
        hTopStackView.distribution  = UIStackView.Distribution.equalSpacing
        hTopStackView.alignment = UIStackView.Alignment.center
        hTopStackView.layoutMargins = UIEdgeInsets(top: 0, left: edgeInsets.left, bottom: 0, right: 10.0)
        hTopStackView.isLayoutMarginsRelativeArrangement = true

        hTopStackView.addArrangedSubview(titleCardForm)
        hTopStackView.addArrangedSubview(closeButton)
        hTopStackView.translatesAutoresizingMaskIntoConstraints = false

        // HBottomStack view for switch button
        hBottomStackView.axis   = NSLayoutConstraint.Axis.horizontal
        hBottomStackView.distribution  = UIStackView.Distribution.fill
        hBottomStackView.alignment = UIStackView.Alignment.center
        hBottomStackView.spacing   = 20.0
        hBottomStackView.layoutMargins = UIEdgeInsets(top: 0, left: edgeInsets.left, bottom: 0, right: 10.0)
        hBottomStackView.isLayoutMarginsRelativeArrangement = true

        hBottomStackView.addArrangedSubview(switchButtonLabel)
        hBottomStackView.addArrangedSubview(switchButton)
        hBottomStackView.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(hTopStackView)
        if paymentConfiguration.showCardSaveSwitch {
            self.contentView.addSubview(hBottomStackView)
        }
        self.contentView.addSubview(confirmButton)

        let hFooterStackView   = UIStackView()
        hFooterStackView.axis  = NSLayoutConstraint.Axis.horizontal
        hFooterStackView.distribution  = UIStackView.Distribution.fill
        hFooterStackView.alignment = UIStackView.Alignment.center
        hFooterStackView.spacing = 3
        hFooterStackView.isLayoutMarginsRelativeArrangement = true

        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let spacerViewRight = UIView()
        spacerViewRight.setContentHuggingPriority(.defaultLow, for: .horizontal)
        hFooterStackView.addArrangedSubview(spacerView)
        hFooterStackView.addArrangedSubview(lockImage)
        hFooterStackView.addArrangedSubview(footerText)
        hFooterStackView.addArrangedSubview(verifoneLogo)
        hFooterStackView.addArrangedSubview(spacerViewRight)
        hFooterStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(hFooterStackView)

        // CARD TITLE
        NSLayoutConstraint.activate([
            titleCardForm.widthAnchor.constraint(equalToConstant: 145),
            titleCardForm.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            // SET FOOTER VIEWS
            lockImage.centerYAnchor.constraint(equalTo: hFooterStackView.centerYAnchor, constant: 0),
            verifoneLogo.centerYAnchor.constraint(equalTo: hFooterStackView.centerYAnchor, constant: 0),
            footerText.centerYAnchor.constraint(equalTo: hFooterStackView.centerYAnchor, constant: 0)
        ])

        NSLayoutConstraint.activate([
            lockImage.widthAnchor.constraint(equalToConstant: 10.0),
            lockImage.heightAnchor.constraint(equalToConstant: 10.0),
            verifoneLogo.heightAnchor.constraint(equalToConstant: 30.0),
            verifoneLogo.widthAnchor.constraint(equalToConstant: 50.0)
        ])

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
            contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0),
            contentView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0),
            contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
            contentView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0.0)
        ])

        // SET CONSTRAINTS TO TOP STACK VIEW
        NSLayoutConstraint.activate([
            hTopStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10.0),
            hTopStackView.heightAnchor.constraint(equalToConstant: 35),
            hTopStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            hTopStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right)
        ])

        // CARD FORM NUMBER INPUT
        NSLayoutConstraint.activate([
            cardFormNumberLabel.topAnchor.constraint(equalTo: hTopStackView.bottomAnchor, constant: 15.0),
            cardFormNumberLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            cardFormNumberLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: edgeInsets.right),
            // CARD NUMBER TEXTFIELD
            cardFormNumberTextField.topAnchor.constraint(equalTo: cardFormNumberLabel.bottomAnchor, constant: 6.0),
            cardFormNumberTextField.heightAnchor.constraint(equalToConstant: 40),
            cardFormNumberTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            cardFormNumberTextField.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: edgeInsets.right),
            // CARD NUMBER ERROR LABEL
            cardFormNumberErrorLabel.topAnchor.constraint(equalTo: cardFormNumberTextField.bottomAnchor, constant: 6.0),
            cardFormNumberErrorLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            cardFormNumberErrorLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right)
        ])

        // CARD FORM EXPIRE INPUT
        NSLayoutConstraint.activate([
            cardFormExpiryDateLabel.topAnchor.constraint(equalTo: cardFormNumberTextField.bottomAnchor, constant: 25.0),
            cardFormExpiryDateLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            // CARD EXPIRE TEXTFIELD
            cardFormExpiryDateTextField.topAnchor.constraint(equalTo: cardFormExpiryDateLabel.bottomAnchor, constant: 6.0),
            cardFormExpiryDateTextField.heightAnchor.constraint(equalToConstant: 40.0),
            cardFormExpiryDateTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            // CARD EXPIRE ERROR LABEL
            cardFormExpiryDateErrorLabel.topAnchor.constraint(equalTo: cardFormExpiryDateTextField.bottomAnchor, constant: 6.0),
            cardFormExpiryDateErrorLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left)
        ])

        // CARD FORM CVC INPUT
        NSLayoutConstraint.activate([
            cardFormCvcLabel.topAnchor.constraint(equalTo: cardFormNumberTextField.bottomAnchor, constant: 25.0),
            cardFormCvcLabel.leadingAnchor.constraint(equalTo: cardFormCvcTextField.leadingAnchor, constant: edgeInsets.left),
            // CARD CVC TEXTFIELD
            cardFormCvcTextField.topAnchor.constraint(equalTo: cardFormCvcLabel.bottomAnchor, constant: 6.0),
            cardFormCvcTextField.heightAnchor.constraint(equalToConstant: 40.0),
            cardFormCvcTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right),
            // CARD CVC ERROR LABEL
            cardFormCVCErrorLabel.topAnchor.constraint(equalTo: cardFormCvcTextField.bottomAnchor, constant: 6.0),
            cardFormCVCErrorLabel.leadingAnchor.constraint(equalTo: cardFormCvcTextField.leadingAnchor, constant: edgeInsets.left)
        ])

        // CARD FORM CVC AND EXPIRE WIDTH AND SPACE
        NSLayoutConstraint.activate([
            cardFormExpiryDateTextField.widthAnchor.constraint(equalTo: cardFormCvcTextField.widthAnchor, constant: 0.0),
            cardFormExpiryDateTextField.trailingAnchor.constraint(equalTo: cardFormCvcTextField.leadingAnchor, constant: -40)
        ])

        // CARD FORM NAME INPUT
        NSLayoutConstraint.activate([
            cardFormNameLabel.topAnchor.constraint(equalTo: cardFormCvcTextField.bottomAnchor, constant: 25.0),
            cardFormNameLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            cardFormNameLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: edgeInsets.right),
            // NAME TEXTFIELD
            cardFormNameTextField.topAnchor.constraint(equalTo: self.cardFormNameLabel.bottomAnchor, constant: 6.0),
            cardFormNameTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            cardFormNameTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right),
            cardFormNameTextField.heightAnchor.constraint(equalToConstant: 40),
            // NAME ERROR LABEL
            cardFormNameErrorLabel.topAnchor.constraint(equalTo: cardFormNameTextField.bottomAnchor, constant: 6.0),
            cardFormNameErrorLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            cardFormNameErrorLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: edgeInsets.right)
        ])

        // BOTTOM STACKVIEW
        if paymentConfiguration.showCardSaveSwitch {
            NSLayoutConstraint.activate([
                hBottomStackView.topAnchor.constraint(equalTo: cardFormNameTextField.bottomAnchor, constant: 20.0),
                hBottomStackView.heightAnchor.constraint(equalToConstant: 40.0),
                confirmButton.topAnchor.constraint(equalTo: hBottomStackView.bottomAnchor, constant: 20.0),
                hBottomStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0.0),
                hBottomStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -7)
            ])
        } else {
            NSLayoutConstraint.activate([
                confirmButton.topAnchor.constraint(equalTo: cardFormNameTextField.bottomAnchor, constant: 30.0)
            ])
        }

        // CONFIRM BUTTON
        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(equalToConstant: 44.0),
            confirmButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            confirmButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right)
        ])

        // BOTTOM STACK VIEW
        NSLayoutConstraint.activate([
            hFooterStackView.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 5.0),
            hFooterStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -30.0),
            hFooterStackView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0.0)
        ])
    }
}
