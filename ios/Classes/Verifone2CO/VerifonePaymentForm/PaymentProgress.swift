//
//  PaymentProgress.swift
//  Verifone2CO
//

import UIKit

final class PaymentProgress: Verifone2COPaymentForm {

    // MARK: - PROPERTIES
    private(set) var card: Card!
    private(set) var isCardSaveOn: Bool!

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .fill
        view.backgroundColor = UIColor.VF2Co.background
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12.0
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20.0, leading: 20.0, bottom: 20.0, trailing: 20.0)
        return view
    }()

    private lazy var spinnerView: SpinnerView = {
        let spinnerView = SpinnerView()
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        return spinnerView
    }()

    private lazy var progressTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - INITIALIZATION
    init(card: Card, isCardSaveOn: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.card = card
        self.isCardSaveOn = isCardSaveOn
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.createToken()
    }

    private func createToken() {
        self.cardTokenisation(card: self.card) { [weak self] token, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    if let error = error {
                        self.paymentConfiguration.delegate?.paymentFormComplete(.failure(error))
                    }
                    if let token = token {
                        let result = PaymentFormResult(token: token.token, isCardSaveOn: self.isCardSaveOn, cardHolder: self.card.cardHolder, paymentMethod: .creditCard)
                        self.paymentConfiguration.delegate?.paymentFormComplete(.success(result))
                    }
                    self.paymentConfiguration.delegate?.paymentFormWillClose()
                }
            }
        }
    }

    private func configureViews() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.stackView.addArrangedSubview(spinnerView)
        self.stackView.addArrangedSubview(progressTextLabel)
        self.view.addSubview(stackView)
        progressTextLabel.text = ""
        NSLayoutConstraint.activate([
            self.stackView.heightAnchor.constraint(equalToConstant: 140.0),
            self.stackView.widthAnchor.constraint(equalToConstant: 140.0),
            self.stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.spinnerView.topAnchor.constraint(equalTo: self.stackView.topAnchor, constant: 35.0),
            self.spinnerView.heightAnchor.constraint(equalToConstant: 70.0),
            self.spinnerView.widthAnchor.constraint(equalToConstant: 70.0)
        ])
    }

    @objc func close() {
        self.dismiss(animated: true)
    }

    @discardableResult
    public class func present(paymentConfiguration: Verifone2CO.PaymentConfiguration, card: Card, isCardSaveOn: Bool,  from: UIViewController) -> Verifone2COPaymentForm {
        let controller = PaymentProgress(card: card, isCardSaveOn: isCardSaveOn)
        controller.paymentConfiguration = paymentConfiguration
        controller.presentDefault(from: from)
        return controller
    }
}
