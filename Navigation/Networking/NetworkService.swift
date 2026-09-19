import Foundation

enum NetworkServiceError: LocalizedError {
    case invalidResponse
    case invalidStatusCode(Int)
    case emptyData

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Сервер вернул некорректный ответ."
        case .invalidStatusCode(let statusCode):
            return "Сервер вернул HTTP-код \(statusCode)."
        case .emptyData:
            return "Сервер не вернул данные."
        }
    }
}

struct NetworkService {
    static func request(
        url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        print("[NetworkService] Request URL: \(url.absoluteString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                let nsError = error as NSError
                print("[NetworkService] Error: \(error.localizedDescription)")
                print("[NetworkService] Error code: \(nsError.code)")
                // При отсутствии интернет-соединения URLSession возвращает
                // NSURLErrorNotConnectedToInternet с кодом -1009.
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[NetworkService] HTTP response is unavailable")
                completion(.failure(NetworkServiceError.invalidResponse))
                return
            }

            print("[NetworkService] Status code: \(httpResponse.statusCode)")
            print("[NetworkService] Headers: \(httpResponse.allHeaderFields)")

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkServiceError.invalidStatusCode(httpResponse.statusCode)))
                return
            }

            guard let data else {
                print("[NetworkService] Response data is empty")
                completion(.failure(NetworkServiceError.emptyData))
                return
            }

            if let body = String(data: data, encoding: .utf8) {
                print("[NetworkService] Data:\n\(body)")
            } else {
                print("[NetworkService] Unable to decode response data as UTF-8")
            }

            completion(.success(data))
        }

        task.resume()
    }
}
