import UIKit

class FeedViewController: UIViewController {
    private let showPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Post", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Feed"
        view.addSubview(showPostButton)
        NSLayoutConstraint.activate([
            showPostButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showPostButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            showPostButton.widthAnchor.constraint(equalToConstant: 200),
            showPostButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        showPostButton.addTarget(self, action: #selector(openPost), for: .touchUpInside)
    }

    @objc func openPost() {
        let post = Post(title: "My Post Title")
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}
