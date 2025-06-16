import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let posts: [Post] = [
        Post(
            author: "Нетология. Меряем карьеру через образование.",
            description: "От 'Hello, World' до первого сложного iOS-приложения — всего один курс. Если чувствуете в себе силу для покорения топов AppStore — пора начинать действовать! Профессия «iOS-разработчик» — тот самый путь, по которому стоит пройти до самого конца. Вы научитесь создавать приложения на языке Swift с нуля: от начинки до интерфейса. Чтобы закрепить знания на практике, каждый студент подготовит дипломную работу — VK-like приложение с возможностью публиковать фотографии, использовать фильтры, ставить лайки и подписываться на других пользователей.",
            image: "post1",
            likes: 766,
            views: 893
        ),
        Post(
            author: "vedmak.official",
            description: "Новые кадры со съемок второго сезона сериала \"Ведьмак\"",
            image: "post2",
            likes: 240,
            views: 312
        ),
        Post(
            author: "appleinsider.ru", 
            description: "Слухи: Apple работает над складным iPhone с двумя экранами",
            image: "post3",
            likes: 156,
            views: 289
        ),
        Post(
            author: "swift.programming",
            description: "SwiftUI vs UIKit: какой фреймворк выбрать для разработки в 2024 году? Разбираем плюсы и минусы каждого подхода.",
            image: "post4",
            likes: 324,
            views: 445
        )
    ]
    
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
        
        // Устанавливаем header для секции
        let headerView = ProfileHeaderView()
        tableView.tableHeaderView = headerView
        
        // Нужно установить размер header view
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 220)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]
        cell.configure(with: post)
        return cell
    }
}

// MARK: - UITableViewDelegate  
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
} 