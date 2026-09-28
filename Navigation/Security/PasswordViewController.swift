import UIKit

final class PasswordViewController: UIViewController {

    enum Mode {
        case unlock
        case create
        case change

        var initialButtonTitle: String {
            switch self {
            case .unlock:
                return "Введите пароль"
            case .create, .change:
                return "Создать пароль"
            }
        }

        var title: String {
            switch self {
            case .unlock:
                return "Введите пароль"
            case .create:
                return "Создание пароля"
            case .change:
                return "Поменять пароль"
            }
        }
    }

    private let passwordStorage: PasswordStorage
    private let mode: Mode
    private let onSuccess: () -> Void

    private var firstPassword: String?

    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Пароль"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var actionButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = mode.initialButtonTitle
        configuration.cornerStyle = .medium

        let button = UIButton(configuration: configuration)
        button.addTarget(
            self,
            action: #selector(actionButtonTapped),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(
        passwordStorage: PasswordStorage,
        mode: Mode,
        onSuccess: @escaping () -> Void
    ) {
        self.passwordStorage = passwordStorage
        self.mode = mode
        self.onSuccess = onSuccess
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = mode.title
        view.backgroundColor = .systemBackground

        passwordTextField.delegate = self

        view.addSubview(instructionLabel)
        view.addSubview(passwordTextField)
        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            instructionLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -90
            ),
            instructionLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 32
            ),
            instructionLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -32
            ),

            passwordTextField.topAnchor.constraint(
                equalTo: instructionLabel.bottomAnchor,
                constant: 24
            ),
            passwordTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 32
            ),
            passwordTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -32
            ),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            actionButton.topAnchor.constraint(
                equalTo: passwordTextField.bottomAnchor,
                constant: 16
            ),
            actionButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 32
            ),
            actionButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -32
            ),
            actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        resetState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }

    @objc private func actionButtonTapped() {
        let password = passwordTextField.text ?? ""

        switch mode {
        case .unlock:
            unlock(with: password)
        case .create, .change:
            createPassword(with: password)
        }
    }

    private func unlock(with password: String) {
        guard passwordStorage.matches(password: password) else {
            showError("Неверный пароль.")
            passwordTextField.text = nil
            return
        }

        passwordTextField.resignFirstResponder()
        onSuccess()
    }

    private func createPassword(with password: String) {
        guard password.count >= 4 else {
            showError("Пароль должен содержать минимум 4 символа.")
            return
        }

        guard let firstPassword else {
            self.firstPassword = password
            passwordTextField.text = nil
            instructionLabel.text = "Введите тот же пароль ещё раз."
            setButtonTitle("Повторите пароль")
            return
        }

        guard firstPassword == password else {
            showError("Пароли не совпадают. Попробуйте ещё раз.")
            resetState()
            return
        }

        do {
            try passwordStorage.save(password: password)
            passwordTextField.resignFirstResponder()
            onSuccess()
        } catch {
            showError(error.localizedDescription)
            resetState()
        }
    }

    private func resetState() {
        firstPassword = nil
        passwordTextField.text = nil
        setButtonTitle(mode.initialButtonTitle)

        switch mode {
        case .unlock:
            instructionLabel.text = "Введите сохранённый пароль."
        case .create, .change:
            instructionLabel.text = "Придумайте пароль минимум из 4 символов."
        }
    }

    private func setButtonTitle(_ title: String) {
        var configuration = actionButton.configuration
        configuration?.title = title
        actionButton.configuration = configuration
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PasswordViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        actionButtonTapped()
        return true
    }
}
