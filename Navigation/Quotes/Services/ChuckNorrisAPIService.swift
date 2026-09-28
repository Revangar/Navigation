import Foundation

protocol ChuckNorrisAPIServiceProtocol {
    func fetchRandomQuote() async throws -> ChuckNorrisQuoteDTO
}

enum ChuckNorrisAPIError: LocalizedError {
    case invalidResponse
    case unexpectedStatusCode(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Сервер вернул некорректный ответ."
        case .unexpectedStatusCode(let code):
            return "Сервер вернул HTTP \(code)."
        }
    }
}

final class ChuckNorrisAPIService: ChuckNorrisAPIServiceProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let randomQuoteURL: URL

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        guard let url = URL(
            string: "https://api.chucknorris.io/jokes/random"
        ) else {
            preconditionFailure("Invalid Chuck Norris API URL")
        }

        self.session = session
        self.decoder = decoder
        self.randomQuoteURL = url
    }

    func fetchRandomQuote() async throws -> ChuckNorrisQuoteDTO {
        try await request(randomQuoteURL)
    }

    private func request<T: Decodable>(
        _ url: URL
    ) async throws -> T {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChuckNorrisAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw ChuckNorrisAPIError.unexpectedStatusCode(
                httpResponse.statusCode
            )
        }

        return try decoder.decode(T.self, from: data)
    }
}
