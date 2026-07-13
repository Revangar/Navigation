import UIKit
import SnapKit

protocol ProfileHeaderViewDelegate: AnyObject {
    func avatarTapped(sourceView: UIImageView)
}

final class ProfileHeaderView: UIView {

    weak var delegate: ProfileHeaderViewDelegate?

    // MARK: - UI Elements

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hipster Cat"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting for something..."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let statusTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Set your status..."
        textField.font = .systemFont(ofSize: 15, weight: .regular)
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 40))
        textField.leftViewMode = .always
        return textField
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set status", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.7
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .systemGray5

        addSubviews()
        setupConstraints()
        configureAvatar()
        setupActions()
    }

    private func addSubviews() {
        addSubview(avatarImageView)
        addSubview(fullNameLabel)
        addSubview(statusLabel)
        addSubview(statusTextField)
        addSubview(actionButton)
    }

    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.size.equalTo(110)
        }

        fullNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(fullNameLabel.snp.bottom).offset(24)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        statusTextField.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        actionButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.top.greaterThanOrEqualTo(statusTextField.snp.bottom).offset(16)
        }
    }

    private func setupActions() {
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func buttonTapped() {
        guard
            let text = statusTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty
        else {
            return
        }

        statusLabel.text = text
        statusTextField.text = nil
        statusTextField.resignFirstResponder()
    }

    @objc private func avatarTapped() {
        delegate?.avatarTapped(sourceView: avatarImageView)
    }

    // MARK: - Avatar

    private func configureAvatar() {
        if let image = UIImage(named: "avatar") {
            avatarImageView.image = image
            return
        }

        let size = CGSize(width: 110, height: 110)
        avatarImageView.image = UIGraphicsImageRenderer(size: size).image { context in
            let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor] as CFArray

            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 1]
            ) else {
                return
            }

            context.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }

    // MARK: - Public Methods

    func avatarFrame(in targetView: UIView) -> CGRect {
        avatarImageView.convert(avatarImageView.bounds, to: targetView)
    }

    func setAvatarHidden(_ hidden: Bool) {
        avatarImageView.alpha = hidden ? 0 : 1
    }
}
