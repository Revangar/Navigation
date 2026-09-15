import Foundation

enum InfoModelError: LocalizedError {
    case invalidTodoJSON

    var errorDescription: String? {
        switch self {
        case .invalidTodoJSON:
            return "Не удалось преобразовать JSON задачи в модель Todo."
        }
    }
}

struct Todo {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool

    init(jsonObject: Any) throws {
        guard
            let dictionary = jsonObject as? [String: Any],
            let userId = dictionary["userId"] as? Int,
            let id = dictionary["id"] as? Int,
            let title = dictionary["title"] as? String,
            let completed = dictionary["completed"] as? Bool
        else {
            throw InfoModelError.invalidTodoJSON
        }

        self.userId = userId
        self.id = id
        self.title = title
        self.completed = completed
    }
}

struct Planet: Decodable {
    let name: String
    let orbitalPeriod: String
    let residents: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case orbitalPeriod = "orbital_period"
        case residents
    }
}

struct Resident: Decodable {
    let name: String
}
