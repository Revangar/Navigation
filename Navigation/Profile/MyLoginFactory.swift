struct MyLoginFactory: LoginFactory {
    func makeLoginInspector() -> LoginInspector {
        LoginInspector()
    }
}
