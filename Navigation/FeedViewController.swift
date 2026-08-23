import UIKit
import StorageService

class FeedViewController: UIViewController {

    // MARK: - Model
    private let model = FeedModel(secretWord: "swift")

    // MARK: - UI
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var firstPostButton = CustomButton(
        title: "Открыть первый пост",
        backgroundColor: .systemBlue,
        cornerRadius: 8
    ) { [weak self] in
        self?.openFirstPost()
    }

    private lazy var secondPostButton = CustomButton(
        title: "Открыть второй пост",
        backgroundColor: .systemGreen,
        cornerRadius: 8
    ) { [weak self] in
        self?.openSecondPost()
    }

    private let guessTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите секретное слово"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var checkGuessButton = CustomButton(
        title: "Проверить слово",
        backgroundColor: .systemIndigo
    ) { [weak self] in
        self?.checkGuess()
    }

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите слово для проверки"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Feed"

        setupUI()
        setupConstraints()
        subscribeToModel()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(stackView)

        stackView.addArrangedSubview(firstPostButton)
        stackView.addArrangedSubview(secondPostButton)
        stackView.setCustomSpacing(24, after: secondPostButton)
        stackView.addArrangedSubview(guessTextField)
        stackView.addArrangedSubview(checkGuessButton)
        stackView.addArrangedSubview(resultLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            firstPostButton.heightAnchor.constraint(equalToConstant: 50),
            secondPostButton.heightAnchor.constraint(equalToConstant: 50),
            guessTextField.heightAnchor.constraint(equalToConstant: 50),
            checkGuessButton.heightAnchor.constraint(equalToConstant: 50),
            resultLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])
    }

    private func subscribeToModel() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGuessResult),
            name: .feedModelDidCheckWord,
            object: model
        )
    }

    // MARK: - Guess flow
    private func checkGuess() {
        let word = guessTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !word.isEmpty else {
            resultLabel.text = "Введите слово"
            resultLabel.textColor = .secondaryLabel
            return
        }

        model.check(word: word)
    }

    @objc private func handleGuessResult(_ notification: Notification) {
        guard let isCorrect = notification.userInfo?[FeedModel.UserInfoKey.isCorrect] as? Bool else {
            return
        }

        resultLabel.text = isCorrect ? "Верно" : "Неверно"
        resultLabel.textColor = isCorrect ? .systemGreen : .systemRed
    }

    // MARK: - Posts
    private func openFirstPost() {
        let post = Post(
            author: "Первый автор",
            description: "Описание первого поста",
            image: "post1",
            likes: 100,
            views: 150
        )
        let viewController = PostViewController(post: post)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func openSecondPost() {
        let post = Post(
            author: "Второй автор",
            description: "Описание второго поста",
            image: "post2",
            likes: 200,
            views: 250
        )
        let viewController = PostViewController(post: post)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
