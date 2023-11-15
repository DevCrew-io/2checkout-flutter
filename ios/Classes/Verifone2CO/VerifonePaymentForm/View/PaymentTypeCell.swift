//
//  PaymentTypeCell.swift
//  Verifone2CO
//

import UIKit

final class PaymentTypeCell: UITableViewCell {

    // MARK: - Properties
    private struct Constants {
        static let contentInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        static let avatarSize = CGSize(width: 36.0, height: 36.0)
    }

    // MARK: - Views

    private let cardBrandImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8.0
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.VF2Co.defaultBlackLabelColor
        label.font = UIFont(name: "Lato-Bold", size: 17.0)
        label.backgroundColor = .clear
        return label
    }()

    private lazy var cardStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardBrandImageView, cardStackView])
        stackView.alignment = .center
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        cardBrandImageView.contentMode = ContentMode.scaleAspectFit
        backgroundColor = UIColor.VF2Co.background
        isAccessibilityElement = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.VF2Co.background
        selectedBackgroundView = backgroundView

        contentView.addSubview(stackView)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupConstraints() {
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.contentInsets.top).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: Constants.contentInsets.left).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.contentInsets.right).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.contentInsets.bottom).isActive = true

        let cardBrandWidthConstriant = cardBrandImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize.width)
        let cardBrandHeightConstraint = cardBrandImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize.height)

        [cardBrandWidthConstriant, cardBrandHeightConstraint].forEach {
            $0.priority = UILayoutPriority(UILayoutPriority.required.rawValue - 1)
            $0.isActive = true
        }
    }

    // MARK: - Highlight

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - View Configuration

    func configure(with item: PaymentMethodType) {
        let image = item.rawValue.replacingOccurrences(of: " ", with: "_")
        self.cardBrandImageView.image = UIImage(named: image, in: .module, compatibleWith: nil)!
        self.nameLabel.text = item.rawValue.description
        self.accessoryType = .disclosureIndicator
        self.cardBrandImageView.contentMode = ContentMode.scaleAspectFit
    }
}
