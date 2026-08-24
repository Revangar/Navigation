import UIKit

protocol ProfileHeaderViewDelegate: AnyObject {
    func avatarTapped(sourceView: UIImageView)
}

final class ProfileHeaderView: UIView {

    weak var delegate: ProfileHeaderViewDelegate?

    // MARK: - UI
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hipster Cat"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting for something..."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Set your status.."
        textField.font = .systemFont(ofSize: 15, weight: .regular)
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 40))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var actionButton: CustomButton = {
        let button = CustomButton(
            title: "Set status",
            titleColor: .white,
            backgroundColor: .systemBlue,
            cornerRadius: 12
        ) { [weak self] in
            self?.setStatus()
        }

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.7
        return button
    }()

    // MARK: - Avatar constraints
    private var avatarTop: NSLayoutConstraint!
    private var avatarLeading: NSLayoutConstraint!
    private var avatarWidth: NSLayoutConstraint!
    private var avatarHeight: NSLayoutConstraint!

    private var avatarCenterX: NSLayoutConstraint!
    private var avatarCenterY: NSLayoutConstraint!
    private var avatarFullWidth: NSLayoutConstraint!

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
        activateConstraints()

        avatarCenterX = avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        avatarCenterY = avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        avatarFullWidth = avatarImageView.widthAnchor.constraint(equalTo: widthAnchor)

        avatarCenterX.isActive = false
        avatarCenterY.isActive = false
        avatarFullWidth.isActive = false

        avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor).isActive = true

        configureAvatar()

        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(tap)
    }

    private func addSubviews() {
        addSubview(avatarImageView)
        addSubview(fullNameLabel)
        addSubview(statusLabel)
        addSubview(statusTextField)
        addSubview(actionButton)
    }

    private func activateConstraints() {
        avatarTop = avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16)
        avatarLeading = avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        avatarWidth = avatarImageView.widthAnchor.constraint(equalToConstant: 110)
        avatarHeight = avatarImageView.heightAnchor.constraint(equalToConstant: 110)

        NSLayoutConstraint.activate([
            avatarTop,
            avatarLeading,
            avatarWidth,
            avatarHeight,

            fullNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            fullNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            fullNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            statusLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            statusTextField.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            statusTextField.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            statusTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statusTextField.heightAnchor.constraint(equalToConstant: 40),

            actionButton.topAnchor.constraint(equalTo: statusTextField.bottomAnchor, constant: 16),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func configureAvatar() {
        if let image = UIImage(named: "avatar") {
            avatarImageView.image = image
        } else {
            let size = CGSize(width: 110, height: 110)
            let placeholder = UIGraphicsImageRenderer(size: size).image { context in
                let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor] as CFArray
                if let gradient = CGGradient(
                    colorsSpace: CGColorSpaceCreateDeviceRGB(),
                    colors: colors,
                    locations: [0, 1]
                ) {
                    context.cgContext.drawLinearGradient(
                        gradient,
                        start: .zero,
                        end: CGPoint(x: size.width, y: size.height),
                        options: []
                    )
                }
            }
            avatarImageView.image = placeholder
        }
    }

    // MARK: - Actions
    private func setStatus() {
        guard let text = statusTextField.text, !text.isEmpty else { return }
        statusLabel.text = text
        statusTextField.text = ""
    }

    @objc private func avatarTapped() {
        delegate?.avatarTapped(sourceView: avatarImageView)
    }

    // MARK: - Public API
    func configure(with user: User) {
        avatarImageView.image = user.avatar
        fullNameLabel.text = user.fullName
        statusLabel.text = user.status
    }

    func avatarFrame(in targetView: UIView) -> CGRect {
        avatarImageView.convert(avatarImageView.bounds, to: targetView)
    }

    func setAvatarHidden(_ hidden: Bool) {
        avatarImageView.alpha = hidden ? 0 : 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }
}
