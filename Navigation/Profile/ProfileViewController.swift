import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // штатный разделитель
        tableView.separatorStyle  = .singleLine
        tableView.separatorInset  = .zero
        tableView.separatorColor  = .systemGray4
        
        // светло-серый фон
        tableView.backgroundColor = .systemGray5
        return tableView
    }()
    
    private let posts = PostsStorage.posts
    
    // MARK: – Avatar fullscreen helpers
    private var avatarSnapshot: UIImageView?
    private var overlayView:  UIView?
    private var closeButton:  UIButton?
    private weak var originalAvatar: UIImageView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        setupTableView()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Регистрируем ячейку
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostTableViewCell")
        tableView.register(PhotosTableViewCell.self,
                           forCellReuseIdentifier: PhotosTableViewCell.identifier)
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
        return 2   // 0 – Photos, 1 – Posts
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PhotosTableViewCell.identifier,
                for: indexPath) as! PhotosTableViewCell
            
            let firstFour = (1...4).compactMap { UIImage(named: "photo\($0)") }
            cell.configure(with: firstFour)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PostTableViewCell",
                for: indexPath) as! PostTableViewCell
            
            let post = posts[indexPath.row]
            cell.configure(with: post)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 28 + 12 + tableView.bounds.width / 4 + 12   // label + offsets + stack
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = ProfileHeaderView()
            header.delegate = self          // назначаем делегата
            return header
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 230
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Ячейка «Photos» — в секции 0
        if indexPath.section == 0 {
            let vc = PhotosViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: – Avatar fullscreen
extension ProfileViewController: ProfileHeaderViewDelegate {

    func avatarTapped(sourceView: UIImageView) {
        presentAvatarFullscreen(from: sourceView)
    }

    private func presentAvatarFullscreen(from avatar: UIImageView) {

        // исходный frame (в координатах контроллера)
        let originFrame = avatar.convert(avatar.bounds, to: view)

        // снимок
        let snap = UIImageView(image: avatar.image)
        snap.contentMode = .scaleAspectFill
        snap.clipsToBounds = true
        snap.layer.cornerRadius = avatar.layer.cornerRadius
        snap.frame = originFrame
        view.addSubview(snap)
        avatarSnapshot = snap

        // overlay
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlay.alpha = 0
        view.insertSubview(overlay, belowSubview: snap)
        overlayView = overlay

        // close button
        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        close.tintColor = .white
        close.alpha = 0
        close.addTarget(self, action: #selector(dismissAvatarFullscreen), for: .touchUpInside)
        view.addSubview(close)
        closeButton = close
        close.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            close.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // скрываем оригинальный аватар (если принадлежит ProfileHeaderView)
        (avatar.superview?.superview as? ProfileHeaderView)?.setAvatarHidden(true)
        originalAvatar = avatar

        // целевые параметры
        let targetSide = view.bounds.width
        let targetCenter = view.center

        UIView.animate(withDuration: 0.5, animations: {
            snap.bounds.size = CGSize(width: targetSide, height: targetSide)
            snap.center = targetCenter
            snap.layer.cornerRadius = 0                // звёздочка: radius → 0
            overlay.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                close.alpha = 1
            }
        }
    }

    @objc private func dismissAvatarFullscreen() {
        guard
            let snap = avatarSnapshot,
            let overlay = overlayView,
            let close = closeButton,
            let avatar = originalAvatar
        else { return }

        close.alpha = 0

        let originFrame = avatar.convert(avatar.bounds, to: view)

        UIView.animate(withDuration: 0.5, animations: {
            snap.frame = originFrame
            snap.layer.cornerRadius = avatar.layer.cornerRadius
            overlay.alpha = 0
        }) { _ in
            snap.removeFromSuperview()
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
