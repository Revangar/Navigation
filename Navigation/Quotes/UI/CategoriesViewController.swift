import UIKit

final class CategoriesViewController: UITableViewController {

    private let repository: QuoteRepository
    private var categories: [String] = []

    var onSelectCategory: ((String) -> Void)?

    init(repository: QuoteRepository) {
        self.repository = repository
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Категории"
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "CategoryCell"
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCategories()
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        categories.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryCell",
            for: indexPath
        )

        var configuration = cell.defaultContentConfiguration()
        configuration.text = categories[indexPath.row]
        cell.contentConfiguration = configuration
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectCategory?(categories[indexPath.row])
    }

    private func reloadCategories() {
        do {
            categories = try repository.allCategories()
            tableView.reloadData()
            updateEmptyState()
        } catch {
            showError(error)
        }
    }

    private func updateEmptyState() {
        if categories.isEmpty {
            let label = UILabel()
            label.text = "Категории появятся у сохранённых цитат"
            label.textAlignment = .center
            label.numberOfLines = 0
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
