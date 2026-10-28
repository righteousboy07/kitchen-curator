import SwiftUI

/// Lightweight recipe editor backed by the shared offline RecipeStore.
struct RecipeEditorView: View {
    @EnvironmentObject private var store: RecipeStore
    @Environment(\.dismiss) private var dismiss

    let recipeID: UUID
    @State private var title = ""
    @State private var ingredients: [KitchenIngredient] = []
    @State private var steps: [KitchenStep] = []
    @State private var loaded = false

    private var original: KitchenRecipe? {
        store.recipes.first { $0.id == recipeID }
    }

    var body: some View {
        Form {
            Section("Recipe") {
                TextField("Recipe title", text: $title)
                    .textInputAutocapitalization(.words)
            }
            Section("Ingredients") {
                ForEach($ingredients) { $ingredient in
                    VStack(alignment: .leading) {
                        TextField("Ingredient", text: $ingredient.name)
                        HStack {
                            TextField("Amount", value: $ingredient.quantity, format: .number)
                                .keyboardType(.decimalPad)
                            TextField("Unit", text: Binding(
                                get: { ingredient.unit ?? "" },
                                set: { ingredient.unit = $0.isEmpty ? nil : $0 }
                            ))
                        }
                    }
                }
                .onDelete { ingredients.remove(atOffsets: $0) }
                Button("Add Ingredient", systemImage: "plus") {
                    ingredients.append(KitchenIngredient(id: UUID(), name: "", quantity: nil, unit: nil, note: nil))
                }
            }
            Section("Instructions") {
                ForEach($steps) { $step in
                    TextField("Instruction", text: $step.text, axis: .vertical)
                        .lineLimit(2...8)
                }
                .onDelete { steps.remove(atOffsets: $0) }
                Button("Add Step", systemImage: "plus") {
                    steps.append(KitchenStep(id: UUID(), text: "", durationSeconds: nil))
                }
            }
        }
        .navigationTitle("Edit Recipe")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            guard !loaded, let recipe = original else { return }
            title = recipe.title
            ingredients = recipe.ingredients
            steps = recipe.steps
            loaded = true
        }
    }

    private func save() {
        guard var recipe = original else { return }
        recipe.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        recipe.ingredients = ingredients.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        recipe.steps = steps.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        recipe.updatedAt = Date()
        store.upsert(recipe)
        if store.errorMessage == nil { dismiss() }
    }
}
