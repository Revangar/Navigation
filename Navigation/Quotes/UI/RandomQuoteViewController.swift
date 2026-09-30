import UIKit

final class RandomQuoteViewController: UIViewController {

    private let apiService: ChuckNorrisAPIServiceProtocol
    private let repository: QuoteRepository
    private var loadTask: Task<Void, Never>?

    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.text = "Нажмите «Загрузить», чтобы получить случайную цитату."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var loadButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Загрузить"
        configuration.cornerStyle = .medium

        let button = UIButton(configuration: configuration)
        button.addTarget(
            self,
            action: #selector(loadButtonTapped),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(
        apiService: ChuckNorrisAPIServiceProtocol,
        repository: QuoteRepository
    ) {
        self.apiService = apiService
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Случайная"
        view.backgroundColor = .systemBackground

        view.addSubview(quoteLabel)
        view.addSubview(categoryLabel)
        view.addSubview(statusLabel)
        view.addSubview(activityIndicator)
        view.addSubview(loadButton)

        NSLayoutConstraint.activate([
            quoteLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -80
            ),
            quoteLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            quoteLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),

            categoryLabel.topAnchor.constraint(
                equalTo: quoteLabel.bottomAnchor,
                constant: 16
            ),
            categoryLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            categoryLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),

            statusLabel.topAnchor.constraint(
                equalTo: categoryLabel.bottomAnchor,
                constant: 12
            ),
            statusLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            statusLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),

            activityIndicator.topAnchor.constraint(
                equalTo: statusLabel.bottomAnchor,
                constant: 16
            ),
            activityIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            loadButton.topAnchor.constraint(
                equalTo: activityIndicator.bottomAnchor,
                constant: 16
            ),
            loadButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 32
            ),
            loadButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -32
            ),
            loadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    deinit {
        loadTask?.cancel()
    }

    @objc private func loadButtonTapped() {
        guard loadTask == nil else { return }

        setLoading(true)
        statusLabel.text = nil

        let apiService = apiService
        let repository = repository

        loadTask = Task { [weak self] in
            do {
                let quote = try await apiService.fetchRandomQuote()
                try Task.checkCancellation()

                let saveResult = try repository.save(quote)

                guard let self else { return }

                defer {
                    self.loadTask = nil
                    self.setLoading(false)
                }

                self.show(quote)

                switch saveResult {
                case .saved:
                    self.statusLabel.text = "Сохранено в Realm"
                    self.statusLabel.textColor = .systemGreen

                case .duplicate:
                    self.statusLabel.text = "Такая цитата уже сохранена"
                    self.statusLabel.textColor = .systemOrange
                }
            } catch is CancellationError {
                self?.loadTask = nil
                self?.setLoading(false)
            } catch {
                self?.loadTask = nil
                self?.setLoading(false)
                self?.statusLabel.text = error.localizedDescription
                self?.statusLabel.textColor = .systemRed
            }
        }
    }

    private func show(_ quote: ChuckNorrisQuoteDTO) {
        quoteLabel.text = quote.value
        categoryLabel.text = quote.categories.isEmpty
            ? "Категория: отсутствует"
            : "Категория: " + quote.categories.joined(separator: ", ")
    }

    private func setLoading(_ isLoading: Bool) {
        loadButton.isEnabled = !isLoading

        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
