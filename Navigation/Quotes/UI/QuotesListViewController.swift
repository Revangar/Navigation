import UIKit

final class QuotesListViewController: UITableViewController {

    private let repository: QuoteRepository
    private var quotes: [StoredQuote] = []

    init(repository: QuoteRepository) {
        self.repository = repository
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Все цитаты"
        tableView.register(
            QuoteTableViewCell.self,
            forCellReuseIdentifier: QuoteTableViewCell.reuseIdentifier
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadQuotes()
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        quotes.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: QuoteTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? QuoteTableViewCell
        else {
            return UITableViewCell()
        }

        cell.configure(with: quotes[indexPath.row])
        return cell
    }

    private func reloadQuotes() {
        do {
            quotes = try repository.allQuotes()
            tableView.reloadData()
            updateEmptyState()
        } catch {
            showError(error)
        }
    }

    private func updateEmptyState() {
        if quotes.isEmpty {
            let label = UILabel()
            label.text = "Пока нет сохранённых цитат"
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка Realm",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
