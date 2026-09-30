import UIKit

final class CategoryQuotesViewController: UITableViewController {

    private let category: String
    private let repository: QuoteRepository
    private var quotes: [StoredQuote] = []

    init(
        category: String,
        repository: QuoteRepository
    ) {
        self.category = category
        self.repository = repository
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category
        tableView.register(
            QuoteTableViewCell.self,
            forCellReuseIdentifier: QuoteTableViewCell.reuseIdentifier
        )

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
            quotes = try repository.quotes(in: category)
            tableView.reloadData()
        } catch {
            let alert = UIAlertController(
                title: "Ошибка Realm",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
