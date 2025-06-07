import UIKit

class ProfileHeaderView: UIView {
    // Avatar image view
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemBlue
        imageView.layer.cornerRadius = 60
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // Full name label
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Илья Петров"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    // Status label
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Изучаю iOS разработку"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
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
        return button
    }()
    
    private var statusText: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
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
    
    private func setupActions() {
        setStatusButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        statusTextField.addTarget(self, action: #selector(statusTextChanged), for: .editingChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 16
        let avatarSize: CGFloat = 120
        let spacing: CGFloat = 16
        
        // Avatar
        avatarImageView.frame = CGRect(
            x: padding,
            y: safeAreaInsets.top + padding,
            width: avatarSize,
            height: avatarSize
        )
        
        // Full name label
        let labelX = avatarImageView.frame.maxX + spacing
        let labelWidth = bounds.width - labelX - padding
        
        fullNameLabel.frame = CGRect(
            x: labelX,
            y: avatarImageView.frame.minY + 27,
            width: labelWidth,
            height: 22
        )
        
        // Status label
        statusLabel.frame = CGRect(
            x: labelX,
            y: fullNameLabel.frame.maxY + 8,
            width: labelWidth,
            height: 18
        )
        
        // Status text field
        statusTextField.frame = CGRect(
            x: padding,
            y: avatarImageView.frame.maxY + spacing,
            width: bounds.width - 2 * padding,
            height: 40
        )
        
        // Set status button
        setStatusButton.frame = CGRect(
            x: padding,
            y: statusTextField.frame.maxY + 16,
            width: 150,
            height: 40
        )
    }
    
    @objc private func statusTextChanged(_ textField: UITextField) {
        statusText = textField.text ?? ""
    }
    
    @objc private func buttonPressed() {
        if !statusText.isEmpty {
            statusLabel.text = statusText
            statusTextField.text = ""
            statusText = ""
        }
        print("Status text: '\(statusLabel.text ?? "")'")
    }
}
