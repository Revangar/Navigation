import Foundation

final class AppSettings {

    private enum Keys {
        static let sortAscending = "documents.sortAscending"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Keys.sortAscending: true
        ])
    }

    var sortAscending: Bool {
        get {
            defaults.bool(forKey: Keys.sortAscending)
        }
        set {
            defaults.set(newValue, forKey: Keys.sortAscending)
        }
    }
}
