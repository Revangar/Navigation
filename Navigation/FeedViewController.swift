import UIKit

class FeedViewController: UIViewController {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let firstPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Открыть первый пост", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let secondPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Открыть второй пост", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Feed"
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(firstPostButton)
        stackView.addArrangedSubview(secondPostButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 200),
            stackView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
    
    private func setupActions() {
        firstPostButton.addTarget(self, action: #selector(openFirstPost), for: .touchUpInside)
        secondPostButton.addTarget(self, action: #selector(openSecondPost), for: .touchUpInside)
    }

    @objc private func openFirstPost() {
        let post = Post(
            author: "Первый автор",
            description: "Описание первого поста",
            image: "post1",
            likes: 100,
            views: 150
        )
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openSecondPost() {
        let post = Post(
            author: "Второй автор",
            description: "Описание второго поста",
            image: "post2",
            likes: 200,
            views: 250
        )
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}
