import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let window: UIWindow
    private let passwordStorage: PasswordStorage
    private let appSettings: AppSettings

    init(
        window: UIWindow,
        passwordStorage: PasswordStorage = KeychainPasswordService(),
        appSettings: AppSettings = AppSettings()
    ) {
        self.window = window
        self.passwordStorage = passwordStorage
        self.appSettings = appSettings
    }

    func start() {
        let mode: PasswordViewController.Mode = passwordStorage.hasPassword
            ? .unlock
            : .create

        showPasswordGate(mode: mode)
    }

    private func showPasswordGate(mode: PasswordViewController.Mode) {
        childCoordinators = []

        let passwordViewController = PasswordViewController(
            passwordStorage: passwordStorage,
            mode: mode
        ) { [weak self] in
            self?.showMainInterface()
        }

        let navigationController = UINavigationController(
            rootViewController: passwordViewController
        )

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showMainInterface() {
        let tabBarController = UITabBarController()

        let documentsNavigationController = UINavigationController()
        documentsNavigationController.tabBarItem = UITabBarItem(
            title: "Files",
            image: UIImage(systemName: "folder"),
            tag: 0
        )

        let settingsNavigationController = UINavigationController()
        settingsNavigationController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            tag: 1
        )

        let documentsCoordinator = DocumentsCoordinator(
            navigationController: documentsNavigationController,
            appSettings: appSettings
        )
        let settingsCoordinator = SettingsCoordinator(
            navigationController: settingsNavigationController,
            appSettings: appSettings,
            passwordStorage: passwordStorage
        )

        childCoordinators = [
            documentsCoordinator,
            settingsCoordinator
        ]

        documentsCoordinator.start()
        settingsCoordinator.start()

        tabBarController.viewControllers = [
            documentsNavigationController,
            settingsNavigationController
        ]
        tabBarController.selectedIndex = 0

        UIView.transition(
            with: window,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) {
            self.window.rootViewController = tabBarController
        }
    }
}
