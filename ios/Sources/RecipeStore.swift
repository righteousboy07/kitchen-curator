import Foundation

/// Offline JSON persistence with atomic writes. Intended as an initial
/// store until a SwiftData migration is designed and tested.
@MainActor
final class RecipeStore: ObservableObject {
    @Published private(set) var recipes: [KitchenRecipe] = []
    @Published private(set) var errorMessage: String?

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileURL: URL? = nil) {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        self.fileURL = fileURL ?? support.appendingPathComponent("KitchenCurator/recipes.json")
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    func load() {
        do {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                recipes = []
                errorMessage = nil
                return
            }
            let data = try Data(contentsOf: fileURL)
            let loaded = try decoder.decode([KitchenRecipe].self, from: data)
            guard loaded.allSatisfy({ $0.schemaVersion == 1 }) else {
                throw StoreError.unsupportedVersion
            }
            recipes = loaded
            errorMessage = nil
        } catch {
            // Never overwrite a file that failed to decode.
            errorMessage = "Unable to read saved recipes: \(error.localizedDescription)"
        }
    }

    func upsert(_ recipe: KitchenRecipe) {
        guard errorMessage == nil else { return }
        let old = recipes
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        } else {
            recipes.append(recipe)
        }
        if !save() { recipes = old }
    }

    func delete(id: UUID) {
        guard errorMessage == nil else { return }
        let old = recipes
        recipes.removeAll { $0.id == id }
        if !save() { recipes = old }
    }

    @discardableResult
    private func save() -> Bool {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try encoder.encode(recipes)
            try data.write(to: fileURL, options: .atomic)
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Unable to save recipes: \(error.localizedDescription)"
            return false
        }
    }

    private enum StoreError: LocalizedError {
        case unsupportedVersion
        var errorDescription: String? {
            "This recipe file uses an unsupported schema version."
        }
    }
}
