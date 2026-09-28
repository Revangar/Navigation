import Foundation
import RealmSwift

final class QuoteObject: Object {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var value = ""
    @Persisted var loadedAt = Date()
    @Persisted var categories: List<QuoteCategoryObject>
}

final class QuoteCategoryObject: Object {
    @Persisted(primaryKey: true) var name = ""
    @Persisted(originProperty: "categories") var quotes: LinkingObjects<QuoteObject>
}

struct StoredQuote {
    let id: String
    let value: String
    let loadedAt: Date
    let categories: [String]
}
