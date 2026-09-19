import Foundation

enum InfoDataServiceError: LocalizedError {
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let value):
            return "Некорректный URL: \(value)"
        }
    }
}

struct InfoDataService {
    private let todoURLString = "https://jsonplaceholder.typicode.com/todos/1"
    private let planetURLString = "https://swapi.info/api/planets/1"

    func loadTodo(completion: @escaping (Result<Todo, Error>) -> Void) {
        guard let url = URL(string: todoURLString) else {
            completion(.failure(InfoDataServiceError.invalidURL(todoURLString)))
            return
        }

        NetworkService.request(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    let todo = try Todo(jsonObject: jsonObject)
                    completion(.success(todo))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadPlanet(completion: @escaping (Result<Planet, Error>) -> Void) {
        guard let url = URL(string: planetURLString) else {
            completion(.failure(InfoDataServiceError.invalidURL(planetURLString)))
            return
        }

        NetworkService.request(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let planet = try JSONDecoder().decode(Planet.self, from: data)
                    completion(.success(planet))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadResidents(
        from residentURLStrings: [String],
        completion: @escaping (Result<[Resident], Error>) -> Void
    ) {
        let urls = residentURLStrings.compactMap(URL.init(string:))

        guard urls.count == residentURLStrings.count else {
            let invalidValue = residentURLStrings.first { URL(string: $0) == nil } ?? "unknown"
            completion(.failure(InfoDataServiceError.invalidURL(invalidValue)))
            return
        }

        guard !urls.isEmpty else {
            completion(.success([]))
            return
        }

        let group = DispatchGroup()
        let stateQueue = DispatchQueue(label: "ru.ilyatrundaev.navigation.residents-state")
        var indexedResidents: [(index: Int, resident: Resident)] = []
        var firstError: Error?

        for (index, url) in urls.enumerated() {
            group.enter()

            NetworkService.request(url: url) { result in
                defer { group.leave() }

                switch result {
                case .success(let data):
                    do {
                        let resident = try JSONDecoder().decode(Resident.self, from: data)
                        stateQueue.sync {
                            indexedResidents.append((index, resident))
                        }
                    } catch {
                        stateQueue.sync {
                            if firstError == nil {
                                firstError = error
                            }
                        }
                    }

                case .failure(let error):
                    stateQueue.sync {
                        if firstError == nil {
                            firstError = error
                        }
                    }
                }
            }
        }

        group.notify(queue: .global(qos: .userInitiated)) {
            let snapshot = stateQueue.sync {
                (
                    residents: indexedResidents
                        .sorted { $0.index < $1.index }
                        .map(\.resident),
                    error: firstError
                )
            }

            if let error = snapshot.error {
                completion(.failure(error))
            } else {
                completion(.success(snapshot.residents))
            }
        }
    }
}
