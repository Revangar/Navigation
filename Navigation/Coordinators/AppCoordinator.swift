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

        let mediaNavigationController = UINavigationController()
        mediaNavigationController.tabBarItem = UITabBarItem(
            title: "Media",
            image: UIImage(systemName: "play.rectangle.on.rectangle"),
            tag: 2
        )

        let feedCoordinator = FeedCoordinator(
            navigationController: feedNavigationController
        )
        let profileCoordinator = ProfileCoordinator(
            navigationController: profileNavigationController
        )
        let mediaCoordinator = MediaCoordinator(
            navigationController: mediaNavigationController
        )

        childCoordinators = [
            feedCoordinator,
            profileCoordinator,
            mediaCoordinator
        ]

        feedCoordinator.start()
        profileCoordinator.start()
        mediaCoordinator.start()

        tabBarController.viewControllers = [
            feedNavigationController,
            profileNavigationController,
            mediaNavigationController
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
