import UIKit
import StorageService

protocol PostViewControllerCoordinator: AnyObject {
    func showInfo()
}

final class PostViewController: UIViewController {

    let post: Post
    weak var coordinator: PostViewControllerCoordinator?

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = post.author
        view.backgroundColor = .systemYellow

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Info",
            style: .plain,
            target: self,
            action: #selector(showInfo)
        )
    }

    @objc private func showInfo() {
        coordinator?.showInfo()
    }
}
