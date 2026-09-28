import PhotosUI
import UIKit
import UniformTypeIdentifiers

final class DocumentsViewController: UIViewController {

    private let storageService: DocumentsStorageService
    private let appSettings: AppSettings
    private var items: [DocumentItem] = []

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 72
        tableView.register(
            DocumentTableViewCell.self,
            forCellReuseIdentifier: DocumentTableViewCell.reuseIdentifier
        )
        return tableView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Documents пуст"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(
        storageService: DocumentsStorageService,
        appSettings: AppSettings
    ) {
        self.storageService = storageService
        self.appSettings = appSettings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Documents"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Добавить фотографию",
            style: .plain,
            target: self,
            action: #selector(addPhotoButtonTapped)
        )

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 24
            ),
            emptyLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -24
            )
        ])

        reloadDocuments()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadDocuments()
    }

    @objc private func addPhotoButtonTapped() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func reloadDocuments() {
        do {
            items = try storageService.loadItems(
                sortAscending: appSettings.sortAscending
            )
            tableView.reloadData()
            updateEmptyState()
        } catch {
            showError(error)
        }
    }

    private func updateEmptyState() {
        let isEmpty = items.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func deleteItem(at indexPath: IndexPath) {
        guard items.indices.contains(indexPath.row) else {
            return
        }

        let item = items[indexPath.row]

        do {
            try storageService.delete(item)
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateEmptyState()
        } catch {
            showError(error)
        }
    }

    private func showError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let alert = UIAlertController(
                title: "Ошибка",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))

            if self.presentedViewController == nil {
                self.present(alert, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension DocumentsViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DocumentTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? DocumentTableViewCell
        else {
            return UITableViewCell()
        }

        cell.configure(with: items[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DocumentsViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            let countBeforeDelete = self.items.count
            self.deleteItem(at: indexPath)
            completion(self.items.count < countBeforeDelete)
        }

        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(
            actions: [deleteAction]
        )
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}

// MARK: - PHPickerViewControllerDelegate

extension DocumentsViewController: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider else {
            return
        }

        guard
            let typeIdentifier = provider.registeredTypeIdentifiers.first(
                where: { identifier in
                    UTType(identifier)?.conforms(to: .image) == true
                }
            )
        else {
            return
        }

        let preferredFileExtension = UTType(typeIdentifier)?
            .preferredFilenameExtension

        provider.loadFileRepresentation(
            forTypeIdentifier: typeIdentifier
        ) { [weak self] temporaryURL, error in
            guard let self else { return }

            if let error {
                self.showError(error)
                return
            }

            guard let temporaryURL else {
                return
            }

            do {
                try self.storageService.savePhoto(
                    from: temporaryURL,
                    preferredFileExtension: preferredFileExtension
                )

                DispatchQueue.main.async { [weak self] in
                    self?.reloadDocuments()
                }
            } catch {
                self.showError(error)
            }
        }
    }
}

// MARK: - Cell

private final class DocumentTableViewCell: UITableViewCell {

    static let reuseIdentifier = "DocumentTableViewCell"

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .secondarySystemBackground
        imageView.tintColor = .secondaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, detailsLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .none
        selectionStyle = .none

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(labelsStack)

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            thumbnailImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 52),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 52),

            labelsStack.leadingAnchor.constraint(
                equalTo: thumbnailImageView.trailingAnchor,
                constant: 12
            ),
            labelsStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            labelsStack.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            )
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailImageView.image = nil
        nameLabel.text = nil
        detailsLabel.text = nil
    }

    func configure(with item: DocumentItem) {
        nameLabel.text = item.name
        detailsLabel.text = ByteCountFormatter.string(
            fromByteCount: item.fileSize,
            countStyle: .file
        )

        if item.isImage, let image = UIImage(contentsOfFile: item.url.path) {
            thumbnailImageView.image = image.preparingThumbnail(
                of: CGSize(width: 104, height: 104)
            ) ?? image
        } else {
            thumbnailImageView.image = UIImage(systemName: "doc")
        }
    }
}
