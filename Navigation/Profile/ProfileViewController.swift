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

    // Убираем системный разделитель у секции с фото,
    // чтобы он не «прилипал» к картинкам и не перекрывал наш кастомный.
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // Прячем разделитель, смещая его за пределы экрана
            cell.separatorInset = UIEdgeInsets(top: 0,
                                               left: cell.bounds.width,
                                               bottom: 0,
                                               right: 0)
        } else {
            // Для постов возвращаем стандартный инсет
            cell.separatorInset = .zero
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return ProfileHeaderView()
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
