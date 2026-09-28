import Foundation

struct ChuckNorrisQuoteDTO: Decodable {
    let id: String
    let value: String
    let categories: [String]
}
