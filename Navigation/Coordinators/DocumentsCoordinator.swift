import UIKit

final class DocumentsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let storageService = DocumentsStorageService()
        let viewController = DocumentsViewController(storageService: storageService)

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
}
