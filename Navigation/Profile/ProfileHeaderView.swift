import UIKit

final class ProfileHeaderView: UIView {

    // MARK: - UI-элементы
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode           = .scaleAspectFill
        iv.layer.masksToBounds   = true
        iv.layer.borderWidth     = 3
        iv.layer.borderColor     = UIColor.white.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let fullNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text      = "Hipster Cat"
        lbl.font      = .systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .black
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
 
    private let statusLabel: UILabel = {
        let lbl = UILabel()
        lbl.text      = "Waiting for something..."
        lbl.font      = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .gray
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let statusTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder        = "Set your status.."
        tf.font               = .systemFont(ofSize: 15)
        tf.textColor          = .black
        tf.backgroundColor    = .white
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth  = 1
        tf.layer.borderColor  = UIColor.black.cgColor
        tf.leftView           = UIView(frame: .init(x: 0, y: 0, width: 15, height: 40))
        tf.leftViewMode       = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Show status", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font   = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor    = .systemBlue
        btn.layer.cornerRadius = 4
        btn.layer.shadowColor  = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 4, height: 4)
        btn.layer.shadowRadius = 4
        btn.layer.shadowOpacity = 0.7
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Private
    private let statusOffset: CGFloat = 8          // «чуть ниже» в режиме просмотра
    private var isEditingStatus = false

    // MARK: - Init
    override init(frame: CGRect) { super.init(frame: frame); configure() }
    required init?(coder: NSCoder) { super.init(coder: coder); configure() }

    private func configure() {
        backgroundColor = .systemGray5
        [avatarImageView, fullNameLabel, statusLabel,
         statusTextField, actionButton].forEach(addSubview)

        layoutUI()
        applyViewingLayout()                      // стартовый режим «просмотр»
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        avatarImageView.image = UIImage(named: "avatar")      // или заглушка
    }

    // MARK: - Layout (констрейнты неизменяемы)
    private func layoutUI() {
        // Аватар
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor    .constraint(equalTo: topAnchor, constant: 16),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarImageView.widthAnchor  .constraint(equalToConstant: 110),
            avatarImageView.heightAnchor .constraint(equalToConstant: 110)
        ])

        // Hipster Cat (всегда на 27 pt)
        NSLayoutConstraint.activate([
            fullNameLabel.topAnchor     .constraint(equalTo: topAnchor, constant: 27),
            fullNameLabel.leadingAnchor .constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            fullNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])

        // Статус
        NSLayoutConstraint.activate([
            statusLabel.topAnchor       .constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor   .constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            statusLabel.trailingAnchor  .constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])

        // Текст-поле (всегда «держит» геометрию)
        NSLayoutConstraint.activate([
            statusTextField.topAnchor   .constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            statusTextField.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            statusTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statusTextField.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Кнопка
        NSLayoutConstraint.activate([
            actionButton.topAnchor      .constraint(equalTo: statusTextField.bottomAnchor, constant: 16),
            actionButton.leadingAnchor  .constraint(equalTo: leadingAnchor, constant: 16),
            actionButton.trailingAnchor .constraint(equalTo: trailingAnchor, constant: -16),
            actionButton.heightAnchor   .constraint(equalToConstant: 50),
            actionButton.bottomAnchor   .constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Режимы отображения
    private func applyViewingLayout() {
        statusLabel.transform       = CGAffineTransform(translationX: 0, y: statusOffset) // опущен
        statusTextField.alpha       = 0                                                   // невидим
        actionButton.setTitle("Show status", for: .normal)
        isEditingStatus             = false
    }

    private func applyEditingLayout() {
        statusLabel.transform       = .identity                                           // поднят
        statusTextField.alpha       = 1
        actionButton.setTitle("Set status", for: .normal)
        isEditingStatus             = true
    }

    // MARK: - Кнопка
    @objc private func buttonTapped() {
        if isEditingStatus {
            if let txt = statusTextField.text, !txt.isEmpty { statusLabel.text = txt }
            statusTextField.text = ""; statusTextField.resignFirstResponder()
            UIView.animate(withDuration: 0.25) { self.applyViewingLayout(); self.layoutIfNeeded() }
        } else {
            UIView.animate(withDuration: 0.25) { self.applyEditingLayout(); self.layoutIfNeeded() }
            statusTextField.becomeFirstResponder()
        }
    }

    // MARK: - Круглая аватарка
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }
}
