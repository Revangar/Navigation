import UIKit

class ProfileHeaderView: UIView {
    // 1) Avatar image view
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "avatar")
        iv.layer.cornerRadius = 60
        iv.layer.masksToBounds = true
        return iv
    }()

    // 2) Full name label
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.text = "Илья"
        label.numberOfLines = 1
        return label
    }()

    // 3) Status label
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.text = "Ваш статус"
        label.numberOfLines = 1
        return label
    }()

    // 4) Status button
    private let statusButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Set Status", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return btn
    }()

    // 5) Status text field
    private let statusTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.placeholder = "Enter new status"
        return tf
    }()

    private var statusText: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(avatarImageView, fullNameLabel, statusLabel, statusTextField, statusButton)
        statusButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        statusTextField.addTarget(self, action: #selector(statusTextChanged), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 16
        let avatarSize: CGFloat = 120

        avatarImageView.frame = CGRect(
            x: padding,
            y: padding + safeAreaInsets.top,
            width: avatarSize,
            height: avatarSize
        )

        fullNameLabel.frame = CGRect(
            x: avatarImageView.frame.maxX + padding,
            y: avatarImageView.frame.minY + 16,
            width: bounds.width - avatarImageView.frame.maxX - 2 * padding,
            height: 20
        )

        statusLabel.frame = CGRect(
            x: fullNameLabel.frame.minX,
            y: fullNameLabel.frame.maxY + 8,
            width: fullNameLabel.frame.width,
            height: 20
        )

        statusTextField.frame = CGRect(
            x: padding,
            y: avatarImageView.frame.maxY + padding,
            width: bounds.width - 2 * padding,
            height: 40
        )

        statusButton.frame = CGRect(
            x: padding,
            y: statusTextField.frame.maxY + 8,
            width: 120,
            height: 36
        )
    }

    @objc private func statusTextChanged(_ textField: UITextField) {
        statusText = textField.text ?? ""
    }

    @objc private func buttonPressed() {
        statusLabel.text = statusText
        print("Status set to '\(statusText)'")
    }

    private func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
