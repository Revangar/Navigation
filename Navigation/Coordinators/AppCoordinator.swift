import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let window: UIWindow
    private let tabBarController = UITabBarController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let feedNavigationController = UINavigationController()
        feedNavigationController.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "list.bullet"),
            tag: 0
        )

        let profileNavigationController = UINavigationController()
        profileNavigationController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 1
        )

        let feedCoordinator = FeedCoordinator(
            navigationController: feedNavigationController
        )
        let profileCoordinator = ProfileCoordinator(
            navigationController: profileNavigationController
        )

        childCoordinators = [feedCoordinator, profileCoordinator]

        feedCoordinator.start()
        profileCoordinator.start()

        tabBarController.viewControllers = [
            feedNavigationController,
            profileNavigationController
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
