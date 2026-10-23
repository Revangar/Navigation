import CoreData
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

    // The feed is static course content. Favorites come from the FRC.
    private let feedPosts = PostsStorage.posts
    private var fetchedResultsController: NSFetchedResultsController<LikedPostEntity>?
    private var selectedAuthor: String?

    init(mode: Mode, repository: LikedPostRepository) {
        self.mode = mode
        self.repository = repository
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        fetchedResultsController?.delegate = nil
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
            configureFetchedResultsController()
        }
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch mode {
        case .feed:
            return feedPosts.count
        case .favorites:
            return fetchedResultsController?.sections?.first?.numberOfObjects ?? 0
        }
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PostTableViewCell",
                for: indexPath
            ) as? PostTableViewCell,
            let post = post(at: indexPath)
        else {
            return UITableViewCell()
        }

        cell.configure(with: post)
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
        guard mode == .favorites, let post = post(at: indexPath) else {
            return nil
        }

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            self.repository.delete(post) { [weak self] result in
                switch result {
                case .success(let deleted):
                    // Never mutate the table manually here: the FRC delegate
                    // applies the deletion after viewContext merges the save.
                    completion(deleted)

                case .failure(let error):
                    completion(false)
                    self?.showError(error)
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

    private func post(at indexPath: IndexPath) -> Post? {
        switch mode {
        case .feed:
            guard feedPosts.indices.contains(indexPath.row) else {
                return nil
            }
            return feedPosts[indexPath.row]

        case .favorites:
            guard let controller = fetchedResultsController,
                  let sections = controller.sections,
                  sections.indices.contains(indexPath.section),
                  indexPath.row < sections[indexPath.section].numberOfObjects
            else {
                return nil
            }
            return controller.object(at: indexPath).makePost()
        }
    }

    private func configureFetchedResultsController() {
        guard mode == .favorites else { return }

        fetchedResultsController?.delegate = nil

        do {
            let controller = try repository.makeFetchedResultsController(
                author: selectedAuthor
            )
            try controller.performFetch()

            fetchedResultsController = controller
            controller.delegate = self

            tableView.reloadData()
            updateFavoritesEmptyState()
        } catch {
            showError(error)
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
            message: "Введите часть имени автора публикации.",
            preferredStyle: .alert
        )

        alert.addTextField { [selectedAuthor] textField in
            textField.placeholder = "Часть имени автора"
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
                self.configureFetchedResultsController()
            }
        )

        present(alert, animated: true)
    }

    @objc private func resetAuthorTapped() {
        selectedAuthor = nil
        configureFetchedResultsController()
    }

    @objc private func handleDoubleTap(
        _ gesture: UITapGestureRecognizer
    ) {
        guard let indexPath = tableView.indexPathForRow(
            at: gesture.location(in: tableView)
        ), let post = post(at: indexPath) else {
            return
        }

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
        guard mode == .favorites else { return }

        let isEmpty = fetchedResultsController?.fetchedObjects?.isEmpty ?? true
        guard isEmpty else {
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

    private func showMessage(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showError(_ error: Error) {
        showMessage(
            title: "Ошибка Core Data",
            message: error.localizedDescription
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension PostsListViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        tableView.beginUpdates()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }

        case .delete:
            if let indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

        case .update:
            if let indexPath {
                tableView.reloadRows(at: [indexPath], with: .none)
            }

        case .move:
            if let indexPath, let newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }

        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        tableView.endUpdates()
        updateFavoritesEmptyState()
    }
}
