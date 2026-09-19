import Foundation

enum AppConfiguration: String, CaseIterable {
    case person = "https://swapi.info/api/people/8"
    case starship = "https://swapi.info/api/starships/3"
    case planet = "https://swapi.info/api/planets/5"

    var url: URL? {
        URL(string: rawValue)
    }
}
