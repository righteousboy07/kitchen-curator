import Foundation

/// Portable recipe model for the iOS app. The macOS import/export adapter
/// must explicitly map to this schema before cross-device synchronization.
struct KitchenRecipe: Codable, Identifiable, Hashable {
    var schemaVersion: Int = 1
    var id: UUID
    var title: String
    var sourceURL: URL?
    var servings: Int?
    var ingredients: [KitchenIngredient]
    var steps: [KitchenStep]
    var tags: [String]
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case id, title, servings, ingredients, steps, tags
        case sourceURL = "source_url"
        case updatedAt = "updated_at"
    }
}

struct KitchenIngredient: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var quantity: Double?
    var unit: String?
    var note: String?
}

struct KitchenStep: Codable, Identifiable, Hashable {
    var id: UUID
    var text: String
    var durationSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case id, text
        case durationSeconds = "duration_seconds"
    }
}
