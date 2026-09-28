import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let quotesCoordinator = QuotesCoordinator()
        childCoordinators = [quotesCoordinator]

        quotesCoordinator.start()

        window.rootViewController = quotesCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}
