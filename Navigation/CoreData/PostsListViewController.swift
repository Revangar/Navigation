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

        if mode == .feed {
            configureDoubleTapGesture()
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

    private func reloadPosts() {
        switch mode {
        case .feed:
            posts = PostsStorage.posts
            tableView.reloadData()
            tableView.backgroundView = nil

        case .favorites:
            do {
                posts = try repository.fetchLikedPosts()
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

        do {
            let result = try repository.save(post)

            switch result {
            case .saved:
                showMessage(
                    title: "Сохранено",
                    message: "Пост добавлен в избранное."
                )

            case .alreadySaved:
                showMessage(
                    title: "Уже сохранено",
                    message: "Этот пост уже есть в избранном."
                )
            }
        } catch {
            showError(error)
        }
    }

    private func updateFavoritesEmptyState() {
        guard posts.isEmpty else {
            tableView.backgroundView = nil
            return
        }

        let label = UILabel()
        label.text = "Пока нет понравившихся постов"
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
            UIAlertAction(
                title: "OK",
                style: .default
            )
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
