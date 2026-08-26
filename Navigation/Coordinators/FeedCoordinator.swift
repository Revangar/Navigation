import UIKit
import StorageService

final class FeedCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let model = FeedModel(secretWord: "swift")
        let viewModel = FeedViewModel(model: model)
        let viewController = FeedViewController(viewModel: viewModel)
        viewController.coordinator = self

        navigationController.setViewControllers([viewController], animated: false)
    }

    func showPost(_ post: Post) {
        let viewController = PostViewController(post: post)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }

    func showInfo() {
        let infoViewController = InfoViewController()
        let modalNavigationController = UINavigationController(
            rootViewController: infoViewController
        )
        modalNavigationController.modalPresentationStyle = .fullScreen

        navigationController.visibleViewController?.present(
            modalNavigationController,
            animated: true
        )
    }
}

extension FeedCoordinator: FeedViewControllerCoordinator {}
extension FeedCoordinator: PostViewControllerCoordinator {}
