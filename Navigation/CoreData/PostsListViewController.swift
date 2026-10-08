import StorageService
import UIKit

final class PostsListViewController: UITableViewController {

    enum Mode {
        case feed
        case favorites

        var title: String {
            switch self {
            case .feed:
                return "Лента"
            case .favorites:
                return "Избранное"
            }
        }
    }

    private let mode: Mode
    private let repository: LikedPostRepository
    private var posts: [Post] = []
    private var selectedAuthor: String?

    init(
        mode: Mode,
        repository: LikedPostRepository
    ) {
        self.mode = mode
        self.repository = repository
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = mode.title
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: "PostTableViewCell"
        )

        switch mode {
        case .feed:
            configureDoubleTapGesture()
        case .favorites:
            configureFavoritesNavigation()
        }

        reloadPosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPosts()
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        posts.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PostTableViewCell",
                for: indexPath
            ) as? PostTableViewCell
        else {
            return UITableViewCell()
        }

        cell.configure(with: posts[indexPath.row])
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }

    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        500
    }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard mode == .favorites, posts.indices.contains(indexPath.row) else {
            return nil
        }

        let post = posts[indexPath.row]

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            self.repository.delete(post) { [weak self] result in
                guard let self else {
                    completion(false)
                    return
                }

                switch result {
                case .success(let deleted):
                    completion(deleted)

                    if deleted {
                        // Refetch after the swipe action finishes. The author
                        // filter might have changed while Core Data was deleting.
                        DispatchQueue.main.async { [weak self] in
                            self?.reloadPosts()
                        }
                    }

                case .failure(let error):
                    completion(false)
                    self.showError(error)
                }
            }
        }

        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(
            actions: [deleteAction]
        )
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    private func reloadPosts() {
        switch mode {
        case .feed:
            posts = PostsStorage.posts
            tableView.reloadData()
            tableView.backgroundView = nil

        case .favorites:
            do {
                posts = try repository.fetchLikedPosts(author: selectedAuthor)
                tableView.reloadData()
                updateFavoritesEmptyState()
            } catch {
                showError(error)
            }
        }
    }

    private func configureDoubleTapGesture() {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap(_:))
        )
        gesture.numberOfTapsRequired = 2
        gesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gesture)
    }

    private func configureFavoritesNavigation() {
        let search = UIBarButtonItem(
            title: "Поиск",
            style: .plain,
            target: self,
            action: #selector(searchAuthorTapped)
        )
        let reset = UIBarButtonItem(
            title: "Сброс",
            style: .plain,
            target: self,
            action: #selector(resetAuthorTapped)
        )

        navigationItem.rightBarButtonItems = [search, reset]
    }

    @objc private func searchAuthorTapped() {
        let alert = UIAlertController(
            title: "Поиск по автору",
            message: "Введите точное имя автора публикации.",
            preferredStyle: .alert
        )

        alert.addTextField { [selectedAuthor] textField in
            textField.placeholder = "Имя автора"
            textField.text = selectedAuthor
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.clearButtonMode = .whileEditing
        }

        alert.addAction(
            UIAlertAction(title: "Отмена", style: .cancel)
        )
        alert.addAction(
            UIAlertAction(title: "Применить", style: .default) { [weak self, weak alert] _ in
                guard let self else { return }

                let author = alert?.textFields?.first?.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                self.selectedAuthor = author.isEmpty ? nil : author
                self.reloadPosts()
            }
        )

        present(alert, animated: true)
    }

    @objc private func resetAuthorTapped() {
        selectedAuthor = nil
        reloadPosts()
    }

    @objc private func handleDoubleTap(
        _ gesture: UITapGestureRecognizer
    ) {
        let location = gesture.location(in: tableView)

        guard
            let indexPath = tableView.indexPathForRow(at: location),
            posts.indices.contains(indexPath.row)
        else {
            return
        }

        let post = posts[indexPath.row]

        repository.save(post) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(.saved):
                self.showMessage(
                    title: "Сохранено",
                    message: "Пост добавлен в избранное."
                )

            case .success(.alreadySaved):
                self.showMessage(
                    title: "Уже сохранено",
                    message: "Этот пост уже есть в избранном."
                )

            case .failure(let error):
                self.showError(error)
            }
        }
    }

    private func updateFavoritesEmptyState() {
        guard posts.isEmpty else {
            tableView.backgroundView = nil
            return
        }

        let label = UILabel()
        label.text = selectedAuthor == nil
            ? "Пока нет понравившихся постов"
            : "Для выбранного автора постов не найдено"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0

        tableView.backgroundView = label
    }

    private func showMessage(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        present(alert, animated: true)
    }

    private func showError(_ error: Error) {
        showMessage(
            title: "Ошибка Core Data",
            message: error.localizedDescription
        )
    }
}
