import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        // IOSDT 2.7 continues the Chuck Norris Realm app from assignment 2.3.
        // The Core Data implementation from 2.4-2.6 remains in the project.
        let quotesCoordinator = QuotesCoordinator()
        childCoordinators = [quotesCoordinator]

        quotesCoordinator.start()

        window.rootViewController = quotesCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}
