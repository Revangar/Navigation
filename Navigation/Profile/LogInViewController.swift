import UIKit

protocol LogInViewControllerCoordinator: AnyObject {
    func showProfile(for user: User)
}

class LogInViewController: UIViewController {

    // MARK: - Dependencies
    private let userService: UserService
    var loginDelegate: LoginViewControllerDelegate?
    weak var coordinator: LogInViewControllerCoordinator?

    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let textFieldsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fill
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemGray6
        stack.layer.cornerRadius = 10
        stack.layer.borderWidth = 0.5
        stack.layer.borderColor = UIColor.lightGray.cgColor
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Login"
#if DEBUG
        textField.text = "test"
#else
        textField.text = "hipster"
#endif
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 0
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.autocapitalizationType = .none
        textField.tintColor = .systemBlue
        textField.translatesAutoresizingMaskIntoConstraints = false
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        textField.rightViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.text = "12345"
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 0
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.isSecureTextEntry = true
        textField.tintColor = .systemBlue
        textField.translatesAutoresizingMaskIntoConstraints = false
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        textField.rightViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return textField
    }()

    private lazy var logInButton = CustomButton(
        title: "Log In",
        titleColor: .white,
        backgroundColor: .systemBlue,
        cornerRadius: 10,
        font: .systemFont(ofSize: 16),
        backgroundImage: UIImage(named: "blue_pixel"),
        clipsToBounds: true
    ) { [weak self] in
        self?.logInButtonTapped()
    }

    // MARK: - Initialization
    init(userService: UserService) {
        self.userService = userService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardObservers()
        setupGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(logoImageView)
        contentView.addSubview(textFieldsStackView)
        contentView.addSubview(logInButton)

        textFieldsStackView.addArrangedSubview(emailTextField)
        textFieldsStackView.addArrangedSubview(separatorView)
        textFieldsStackView.addArrangedSubview(passwordTextField)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 120),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),

            textFieldsStackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 120),
            textFieldsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldsStackView.heightAnchor.constraint(equalToConstant: 100),

            separatorView.heightAnchor.constraint(equalToConstant: 0.5),

            logInButton.topAnchor.constraint(equalTo: textFieldsStackView.bottomAnchor, constant: 16),
            logInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            logInButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -50)
        ])
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Actions
    private func logInButtonTapped() {
        let login = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        do {
            let user = try authenticate(login: login, password: password)
            view.endEditing(true)
            coordinator?.showProfile(for: user)
        } catch {
            showLoginError(error)
        }
    }

    private func authenticate(login: String, password: String) throws -> User {
        let normalizedLogin = login.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedLogin.isEmpty else {
            throw NavigationError.emptyLogin
        }

        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NavigationError.emptyPassword
        }

        guard let loginDelegate else {
            throw NavigationError.authenticationUnavailable
        }

        guard loginDelegate.check(login: normalizedLogin, password: password) else {
            throw NavigationError.invalidCredentials
        }

        guard let user = userService.getUser(login: normalizedLogin) else {
            throw NavigationError.userNotFound(login: normalizedLogin)
        }

        return user
    }

    private func showLoginError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка авторизации",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        var activeField: UITextField?
        if emailTextField.isFirstResponder {
            activeField = emailTextField
        } else if passwordTextField.isFirstResponder {
            activeField = passwordTextField
        }

        if let activeField {
            let aRect = view.frame
            let fieldFrame = activeField.convert(activeField.bounds, to: view)
            let visibleRect = CGRect(
                x: aRect.origin.x,
                y: aRect.origin.y,
                width: aRect.size.width,
                height: aRect.size.height - keyboardSize.height
            )

            if !visibleRect.contains(fieldFrame.origin) {
                scrollView.scrollRectToVisible(fieldFrame, animated: true)
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
