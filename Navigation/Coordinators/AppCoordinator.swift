import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let window: UIWindow
    private let tabBarController = UITabBarController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let documentsNavigationController = UINavigationController()
        documentsNavigationController.tabBarItem = UITabBarItem(
            title: "Documents",
            image: UIImage(systemName: "folder"),
            tag: 0
        )

        let feedNavigationController = UINavigationController()
        feedNavigationController.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "list.bullet"),
            tag: 1
        )

        let profileNavigationController = UINavigationController()
        profileNavigationController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 2
        )

        let mediaNavigationController = UINavigationController()
        mediaNavigationController.tabBarItem = UITabBarItem(
            title: "Media",
            image: UIImage(systemName: "play.rectangle.on.rectangle"),
            tag: 3
        )

        let documentsCoordinator = DocumentsCoordinator(
            navigationController: documentsNavigationController
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
            documentsCoordinator,
            feedCoordinator,
            profileCoordinator,
            mediaCoordinator
        ]

        documentsCoordinator.start()
        feedCoordinator.start()
        profileCoordinator.start()
        mediaCoordinator.start()

        tabBarController.viewControllers = [
            documentsNavigationController,
            feedNavigationController,
            profileNavigationController,
            mediaNavigationController
        ]
        tabBarController.selectedIndex = 0

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
