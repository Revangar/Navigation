import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let tabBarController = UITabBarController()

        let feedNav = UINavigationController(rootViewController: FeedViewController())
        feedNav.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "list.bullet"),
            tag: 0
        )

        let userService: UserService
#if DEBUG
        userService = TestUserService()
#else
        let avatar = UIImage(named: "avatar") ?? UIImage()
        let currentUser = User(
            login: "hipster",
            fullName: "Hipster Cat",
            avatar: avatar,
            status: "Waiting for something..."
        )
        userService = CurrentUserService(user: currentUser)
#endif

        let loginFactory: LoginFactory = MyLoginFactory()
        let logInViewController = LogInViewController(userService: userService)
        logInViewController.loginDelegate = loginFactory.makeLoginInspector()

        let profileNav = UINavigationController(rootViewController: logInViewController)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 1
        )

        tabBarController.viewControllers = [feedNav, profileNav]

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called when the scene transitions from the foreground to the background.
    }
}
