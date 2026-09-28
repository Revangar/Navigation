import Foundation
import RealmSwift

enum QuoteSaveResult {
    case saved(StoredQuote)
    case duplicate(StoredQuote)
}

protocol QuoteRepository {
    func save(_ quote: ChuckNorrisQuoteDTO) throws -> QuoteSaveResult
    func allQuotes() throws -> [StoredQuote]
    func allCategories() throws -> [String]
    func quotes(in category: String) throws -> [StoredQuote]
}

final class RealmQuoteRepository: QuoteRepository {

    func save(_ quote: ChuckNorrisQuoteDTO) throws -> QuoteSaveResult {
        let realm = try Realm()

        if let duplicate = existingQuote(
            for: quote,
            in: realm
        ) {
            return .duplicate(makeStoredQuote(from: duplicate))
        }

        let quoteObject = QuoteObject()
        quoteObject.id = quote.id
        quoteObject.value = quote.value
        quoteObject.loadedAt = Date()

        let normalizedCategories = Array(
            Set(
                quote.categories
                    .map {
                        $0.trimmingCharacters(in: .whitespacesAndNewlines)
                            .lowercased()
                    }
                    .filter { !$0.isEmpty }
            )
        )
        .sorted()

        try realm.write {
            realm.add(quoteObject)

            for categoryName in normalizedCategories {
                let category: QuoteCategoryObject

                if let existing = realm.object(
                    ofType: QuoteCategoryObject.self,
                    forPrimaryKey: categoryName
                ) {
                    category = existing
                } else {
                    category = QuoteCategoryObject()
                    category.name = categoryName
                    realm.add(category)
                }

                quoteObject.categories.append(category)
            }
        }

        return .saved(makeStoredQuote(from: quoteObject))
    }

    func allQuotes() throws -> [StoredQuote] {
        let realm = try Realm()

        return realm.objects(QuoteObject.self)
            .sorted(byKeyPath: "loadedAt", ascending: false)
            .map { makeStoredQuote(from: $0) }
    }

    func allCategories() throws -> [String] {
        let realm = try Realm()

        return realm.objects(QuoteCategoryObject.self)
            .sorted(byKeyPath: "name", ascending: true)
            .map(\.name)
    }

    func quotes(in category: String) throws -> [StoredQuote] {
        let realm = try Realm()

        guard let categoryObject = realm.object(
            ofType: QuoteCategoryObject.self,
            forPrimaryKey: category
        ) else {
            return []
        }

        return categoryObject.quotes
            .sorted(byKeyPath: "loadedAt", ascending: false)
            .map { makeStoredQuote(from: $0) }
    }

    private func existingQuote(
        for quote: ChuckNorrisQuoteDTO,
        in realm: Realm
    ) -> QuoteObject? {
        if let byID = realm.object(
            ofType: QuoteObject.self,
            forPrimaryKey: quote.id
        ) {
            return byID
        }

        return realm.objects(QuoteObject.self)
            .filter("value == %@", quote.value)
            .first
    }

    private func makeStoredQuote(
        from object: QuoteObject
    ) -> StoredQuote {
        StoredQuote(
            id: object.id,
            value: object.value,
            loadedAt: object.loadedAt,
            categories: object.categories.map(\.name)
        )
    }
}
