import UIKit
import StorageService

protocol FeedViewControllerCoordinator: AnyObject {
    func showPost(_ post: Post)
}

final class FeedViewController: UIViewController {

    // MARK: - Dependencies
    private let viewModel: FeedViewModel
    weak var coordinator: FeedViewControllerCoordinator?

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
        self?.openPost(at: 0)
    }

    private lazy var secondPostButton = CustomButton(
        title: "Открыть второй пост",
        backgroundColor: .systemGreen,
        cornerRadius: 8
    ) { [weak self] in
        self?.openPost(at: 1)
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
        self?.viewModel.checkGuess(self?.guessTextField.text)
    }

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    // MARK: - Initialization
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Feed"

        setupUI()
        setupConstraints()
        bindViewModel()
        render(viewModel.state)
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

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: FeedViewModel.GuessState) {
        switch state {
        case .idle:
            resultLabel.text = "Введите слово для проверки"
            resultLabel.textColor = .secondaryLabel
        case .empty:
            resultLabel.text = "Введите слово"
            resultLabel.textColor = .secondaryLabel
        case .correct:
            resultLabel.text = "Верно"
            resultLabel.textColor = .systemGreen
        case .incorrect:
            resultLabel.text = "Неверно"
            resultLabel.textColor = .systemRed
        }
    }

    // MARK: - Navigation intent
    private func openPost(at index: Int) {
        guard let post = viewModel.post(at: index) else { return }
        coordinator?.showPost(post)
    }
}
