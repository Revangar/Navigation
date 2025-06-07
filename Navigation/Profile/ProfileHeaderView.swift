import UIKit

class ProfileHeaderView: UIView {
    // Avatar image view
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 55
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Full name label
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Илья Петров"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Status label
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Изучаю iOS разработку"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Status text field
    private let statusTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите новый статус"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 12
        textField.backgroundColor = .systemBackground
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Set status button
    private let setStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Установить статус", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var statusText: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
        setupAvatar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(avatarImageView)
        addSubview(fullNameLabel)
        addSubview(statusLabel)
        addSubview(statusTextField)
        addSubview(setStatusButton)
    }
    
    private func setupAvatar() {
        // Загружаем изображение аватара
        if let avatarImage = UIImage(named: "avatar") {
            print("✅ Avatar image loaded successfully!")
            avatarImageView.image = avatarImage
            avatarImageView.backgroundColor = .clear
        } else {
            print("❌ Avatar image not found, using programmatic avatar")
            // Создаем красивый программный аватар
            avatarImageView.image = createAvatarImage(with: "ИП", size: CGSize(width: 110, height: 110))
            avatarImageView.backgroundColor = .clear
        }
    }
    
    private func createAvatarImage(with initials: String, size: CGSize) -> UIImage {
        // Защита от некорректных размеров
        guard size.width > 0, size.height > 0 else {
            print("⚠️ Warning: Invalid size for avatar creation")
            return UIImage() // Возвращаем пустое изображение
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Создаем градиентный фон
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
            
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) else {
                print("⚠️ Warning: Could not create gradient")
                // Используем однотонный фон как fallback
                UIColor.systemBlue.setFill()
                UIRectFill(CGRect(origin: .zero, size: size))
                return
            }
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Добавляем инициалы с защитой от ошибок
            let fontSize = min(size.width, size.height) * 0.4 // Адаптивный размер шрифта
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            
            let textSize = initials.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            initials.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Avatar constraints - четкие размеры
            avatarImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 110),
            avatarImageView.heightAnchor.constraint(equalToConstant: 110),
            
            // Full name label constraints - фиксированные размеры
            fullNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            fullNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            fullNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 25),
            fullNameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // Status label constraints - фиксированные размеры
            statusLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: fullNameLabel.trailingAnchor),
            statusLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8),
            statusLabel.heightAnchor.constraint(equalToConstant: 18),
            
            // Status text field constraints - четкие размеры
            statusTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            statusTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statusTextField.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            statusTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Set status button constraints - фиксированные размеры и позиция
            setStatusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            setStatusButton.topAnchor.constraint(equalTo: statusTextField.bottomAnchor, constant: 8),
            setStatusButton.widthAnchor.constraint(equalToConstant: 150),
            setStatusButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        // Добавляем constraint с низким приоритетом для bottomAnchor
        let bottomConstraint = setStatusButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        bottomConstraint.priority = UILayoutPriority(999) // Чуть ниже required
        bottomConstraint.isActive = true
    }
    
    private func setupActions() {
        setStatusButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        statusTextField.addTarget(self, action: #selector(statusTextChanged), for: .editingChanged)
    }
    
    @objc private func statusTextChanged(_ textField: UITextField) {
        statusText = textField.text ?? ""
    }
    
    @objc private func buttonPressed() {
        // Защита от одновременных нажатий
        setStatusButton.isEnabled = false
        
        DispatchQueue.main.async { [weak self] in
            defer {
                // Возвращаем кнопку в активное состояние через небольшую задержку
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.setStatusButton.isEnabled = true
                }
            }
            
            guard let self = self else { return }
            
            if !self.statusText.isEmpty {
                self.statusLabel.text = self.statusText
                self.statusTextField.text = ""
                self.statusText = ""
                
                // Плавная анимация обновления
                UIView.animate(withDuration: 0.2) {
                    self.statusLabel.alpha = 0.7
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self.statusLabel.alpha = 1.0
                    }
                }
            }
            
            print("Status text: '\(self.statusLabel.text ?? "")'")
        }
    }
}
