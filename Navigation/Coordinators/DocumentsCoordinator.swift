import UIKit

final class DocumentsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    let navigationController: UINavigationController

    private let appSettings: AppSettings

    init(
        navigationController: UINavigationController,
        appSettings: AppSettings
    ) {
        self.navigationController = navigationController
        self.appSettings = appSettings
    }

    func start() {
        let storageService = DocumentsStorageService()
        let viewController = DocumentsViewController(
            storageService: storageService,
            appSettings: appSettings
        )

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
}
