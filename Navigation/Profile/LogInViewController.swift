import UIKit

protocol LogInViewControllerCoordinator: AnyObject {
    func showProfile(email: String)
}

class LogInViewController: UIViewController {

    // MARK: - Dependencies
    private weak var delegate: LoginViewControllerDelegate?
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
        textField.placeholder = "Email"
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 0
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
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
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 0
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.isSecureTextEntry = true
        textField.textContentType = .password
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

    private lazy var signUpButton = CustomButton(
        title: "Sign Up",
        titleColor: .systemBlue,
        backgroundColor: .systemGray6,
        cornerRadius: 10,
        font: .systemFont(ofSize: 16)
    ) { [weak self] in
        self?.signUpButtonTapped()
    }

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Initialization
    init(delegate: LoginViewControllerDelegate) {
        self.delegate = delegate
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
        contentView.addSubview(signUpButton)
        contentView.addSubview(activityIndicator)

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

            signUpButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 12),
            signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),

            activityIndicator.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 16),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
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
        do {
            let credentials = try validatedCredentials()
            guard let delegate else {
                throw NavigationError.authenticationUnavailable
            }

            setAuthenticationInProgress(true)

            delegate.checkCredentials(
                email: credentials.email,
                password: credentials.password
            ) { [weak self] result in
                self?.handleAuthenticationResult(result, email: credentials.email)
            }
        } catch {
            showLoginError(error)
        }
    }

    private func signUpButtonTapped() {
        do {
            let credentials = try validatedCredentials()
            guard let delegate else {
                throw NavigationError.authenticationUnavailable
            }

            setAuthenticationInProgress(true)

            delegate.signUp(
                email: credentials.email,
                password: credentials.password
            ) { [weak self] result in
                self?.handleAuthenticationResult(result, email: credentials.email)
            }
        } catch {
            showLoginError(error)
        }
    }

    private func validatedCredentials() throws -> (email: String, password: String) {
        let email = (emailTextField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (passwordTextField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty else {
            throw NavigationError.emptyLogin
        }

        guard !password.isEmpty else {
            throw NavigationError.emptyPassword
        }

        return (email, password)
    }

    private func handleAuthenticationResult(
        _ result: Result<Void, Error>,
        email: String
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.setAuthenticationInProgress(false)

            switch result {
            case .success:
                self.view.endEditing(true)
                self.coordinator?.showProfile(email: email)

            case .failure(let error):
                self.showLoginError(error)
            }
        }
    }

    private func setAuthenticationInProgress(_ isInProgress: Bool) {
        logInButton.isEnabled = !isInProgress
        signUpButton.isEnabled = !isInProgress
        emailTextField.isEnabled = !isInProgress
        passwordTextField.isEnabled = !isInProgress

        logInButton.alpha = isInProgress ? 0.6 : 1
        signUpButton.alpha = isInProgress ? 0.6 : 1

        if isInProgress {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
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
        guard let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        )?.cgRectValue else {
            return
        }

        let contentInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardSize.height,
            right: 0
        )

        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        var activeField: UITextField?

        if emailTextField.isFirstResponder {
            activeField = emailTextField
        } else if passwordTextField.isFirstResponder {
            activeField = passwordTextField
        }

        if let activeField {
            let fieldFrame = activeField.convert(activeField.bounds, to: view)
            let visibleRect = CGRect(
                x: view.frame.origin.x,
                y: view.frame.origin.y,
                width: view.frame.width,
                height: view.frame.height - keyboardSize.height
            )

            if !visibleRect.contains(fieldFrame.origin) {
                scrollView.scrollRectToVisible(fieldFrame, animated: true)
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
