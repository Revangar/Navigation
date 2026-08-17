struct LoginInspector: LoginViewControllerDelegate {
    func check(login: String, password: String) -> Bool {
        Checker.shared.check(login: login, password: password)
    }
}
