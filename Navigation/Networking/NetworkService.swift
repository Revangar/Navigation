import Foundation

struct NetworkService {
    static func request(for configuration: AppConfiguration) {
        let urlString: String

        switch configuration {
        case .person(let value):
            urlString = value
        case .starship(let value):
            urlString = value
        case .planet(let value):
            urlString = value
        }

        guard let url = URL(string: urlString) else {
            print("[NetworkService] Invalid URL: \(urlString)")
            return
        }

        print("[NetworkService] Request URL: \(url.absoluteString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                let nsError = error as NSError
                print("[NetworkService] Error: \(error.localizedDescription)")
                print("[NetworkService] Error code: \(nsError.code)")
                // При отсутствии интернет-соединения URLSession возвращает
                // NSURLErrorNotConnectedToInternet с кодом -1009.
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("[NetworkService] Status code: \(httpResponse.statusCode)")
                print("[NetworkService] Headers: \(httpResponse.allHeaderFields)")
            } else {
                print("[NetworkService] HTTP response is unavailable")
            }

            guard let data else {
                print("[NetworkService] Response data is empty")
                return
            }

            if let body = String(data: data, encoding: .utf8) {
                print("[NetworkService] Data:\n\(body)")
            } else {
                print("[NetworkService] Unable to decode response data as UTF-8")
            }
        }

        task.resume()
    }
}
