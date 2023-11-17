//
//  PaymentMethodsForm.swift
//  Verifone2CO
//

import UIKit

final class PaymentMethodsForm: Verifone2COPaymentForm {

    var selectedPaymentMethod: ((PaymentMethodType) -> Void)?

    private var allowedPaymentMethods: [PaymentMethodType] = [.creditCard, .paypal]
    private let headerView = PaymentTypeHeaderView()
    private var headerPresentable: PaymentTypeHeaderPresentable!
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(paymentConfiguration: Verifone2CO.PaymentConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.paymentConfiguration = paymentConfiguration
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.allowedPaymentMethods = self.paymentConfiguration!.allowedPaymentMethods
        configureHeaderView()
        configureConstraints()
        configureTableView()
    }

    // MARK: - Configure Table header view
    private func configureHeaderView() {
        headerPresentable = PaymentTypeHeaderPresentable.init(title: self.paymentConfiguration.paymentPanelStoreTitle)
    }

    // MARK: - Tableview Configurations
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.VF2Co.background
        tableView.insetsContentViewsToSafeArea = false
        tableView.register(PaymentTypeCell.self, forCellReuseIdentifier: PaymentTypeCell.description())
        tableView.reloadData()
    }

    // MARK: - Configure Tableview constraints
    private func configureConstraints() {
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 11, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
            if self.tableView.adjustedContentInset.bottom > 0 {
                self.tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
            }
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    @discardableResult
    public override class func present(with configuration: Verifone2CO.PaymentConfiguration, from: UIViewController) -> Verifone2COPaymentForm {
        let controller = PaymentMethodsForm(paymentConfiguration: configuration)
        controller.presentPan(from: from)
        return controller
    }
}

extension PaymentMethodsForm: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allowedPaymentMethods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentTypeCell.description(), for: indexPath) as? PaymentTypeCell
        else { return UITableViewCell() }
        let item = self.allowedPaymentMethods[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.configure(with: headerPresentable)
        headerView.closeButton.addTarget(self, action: #selector(closeForm(sender:)), for: .touchUpInside)
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.allowedPaymentMethods[indexPath.row]
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.selectedPaymentMethod?(item)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    @objc func closeForm(sender: UIButton) {
        self.paymentConfiguration.delegate?.paymentFormWillClose()
        self.dismiss(animated: true) { 
        }
    }
}
