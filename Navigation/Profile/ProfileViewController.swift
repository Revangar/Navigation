import UIKit

class ProfileViewController: UIViewController {

    // MARK: - Properties
    private let user: User

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.separatorColor = .systemGray4
        tableView.backgroundColor = .systemGray5
        return tableView
    }()

    private let posts = PostsStorage.posts

    // MARK: - Avatar fullscreen helpers
    private var avatarSnapshot: UIImageView?
    private var overlayView: UIView?
    private var closeButton: CustomButton?
    private weak var originalAvatar: UIImageView?

    // MARK: - Initialization
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
#if DEBUG
        view.backgroundColor = .systemBackground
#else
        view.backgroundColor = UIColor(red: 0.09, green: 0.14, blue: 0.28, alpha: 1.0)
#endif
        title = "Profile"
        setupTableView()
        setupConstraints()
    }

    // MARK: - Setup
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostTableViewCell")
        tableView.register(
            PhotosTableViewCell.self,
            forCellReuseIdentifier: PhotosTableViewCell.identifier
        )
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PhotosTableViewCell.identifier,
                for: indexPath
            ) as! PhotosTableViewCell

            let firstFour = (1...4).compactMap { UIImage(named: "photo\($0)") }
            cell.configure(with: firstFour)
            return cell
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PostTableViewCell",
            for: indexPath
        ) as! PostTableViewCell
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 28 + 12 + tableView.bounds.width / 4 + 12
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        400
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }

        let header = ProfileHeaderView()
        header.delegate = self
        header.configure(with: user)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 230 : 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            navigationController?.pushViewController(PhotosViewController(), animated: true)
        }
    }
}

// MARK: - Avatar fullscreen
extension ProfileViewController: ProfileHeaderViewDelegate {
    func avatarTapped(sourceView: UIImageView) {
        presentAvatarFullscreen(from: sourceView)
    }

    private func presentAvatarFullscreen(from avatar: UIImageView) {
        let originFrame = avatar.convert(avatar.bounds, to: view)

        let snapshot = UIImageView(image: avatar.image)
        snapshot.contentMode = .scaleAspectFill
        snapshot.clipsToBounds = true
        snapshot.layer.cornerRadius = avatar.layer.cornerRadius
        snapshot.frame = originFrame
        view.addSubview(snapshot)
        avatarSnapshot = snapshot

        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlay.alpha = 0
        view.insertSubview(overlay, belowSubview: snapshot)
        overlayView = overlay

        let close = CustomButton(
            backgroundColor: .clear,
            cornerRadius: 0,
            image: UIImage(systemName: "xmark.circle.fill"),
            tintColor: .white
        ) { [weak self] in
            self?.dismissAvatarFullscreen()
        }
        close.alpha = 0
        view.addSubview(close)
        closeButton = close

        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            close.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        (avatar.superview?.superview as? ProfileHeaderView)?.setAvatarHidden(true)
        originalAvatar = avatar

        let targetSide = view.bounds.width
        let targetCenter = view.center

        UIView.animate(withDuration: 0.5, animations: {
            snapshot.bounds.size = CGSize(width: targetSide, height: targetSide)
            snapshot.center = targetCenter
            snapshot.layer.cornerRadius = 0
            overlay.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                close.alpha = 1
            }
        }
    }

    private func dismissAvatarFullscreen() {
        guard
            let snapshot = avatarSnapshot,
            let overlay = overlayView,
            let close = closeButton,
            let avatar = originalAvatar
        else {
            return
        }

        close.alpha = 0
        let originFrame = avatar.convert(avatar.bounds, to: view)

        UIView.animate(withDuration: 0.5, animations: {
            snapshot.frame = originFrame
            snapshot.layer.cornerRadius = avatar.layer.cornerRadius
            overlay.alpha = 0
        }) { _ in
            snapshot.removeFromSuperview()
            overlay.removeFromSuperview()
            close.removeFromSuperview()
            (avatar.superview?.superview as? ProfileHeaderView)?.setAvatarHidden(false)

            self.avatarSnapshot = nil
            self.overlayView = nil
            self.closeButton = nil
            self.originalAvatar = nil
        }
    }
}
