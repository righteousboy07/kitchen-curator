import SwiftUI

struct RecipeLibraryView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var query = ""
    @State private var showingAdd = false
    @State private var newTitle = ""

    private var filtered: [KitchenRecipe] {
        store.recipes
            .filter { query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) }
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    var body: some View {
        List {
            ForEach(filtered) { recipe in
                NavigationLink(value: recipe.id) {
                    Label(recipe.title, systemImage: "book.closed")
                }
            }
            .onDelete { offsets in
                let ids = offsets.map { filtered[$0].id }
                ids.forEach { store.delete(id: $0) }
            }
        }
        .searchable(text: $query, prompt: "Search recipes")
        .navigationDestination(for: UUID.self) { id in
            if let recipe = store.recipes.first(where: { $0.id == id }) {
                RecipeDetailView(recipeID: recipe.id)
            } else {
                ContentUnavailableView("Recipe unavailable", systemImage: "book.closed")
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Recipe", systemImage: "plus") { showingAdd = true }
            }
        }
        .alert("New Recipe", isPresented: $showingAdd) {
            TextField("Recipe name", text: $newTitle)
            Button("Cancel", role: .cancel) { newTitle = "" }
            Button("Save") {
                let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !title.isEmpty else { return }
                store.upsert(KitchenRecipe(id: UUID(), title: title, sourceURL: nil, servings: nil, ingredients: [], steps: [], tags: [], updatedAt: Date()))
                newTitle = ""
            }
        } message: {
            Text("Enter a name to add a recipe to your library.")
        }
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }
}

struct RecipeDetailView: View {
    @EnvironmentObject private var store: RecipeStore
    let recipeID: UUID

    private var recipe: KitchenRecipe? {
        store.recipes.first { $0.id == recipeID }
    }

    var body: some View {
        Group {
            if let recipe {
                List {
                    Section("Ingredients") {
                        if recipe.ingredients.isEmpty {
                            Text("No ingredients yet").foregroundStyle(.secondary)
                        }
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Text(ingredient.name)
                                Spacer()
                                if let amount = ingredient.quantity {
                                    Text(amount.formatted())
                                        .foregroundStyle(.secondary)
                                }
                                if let unit = ingredient.unit {
                                    Text(unit).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    Section("Directions") {
                        if recipe.steps.isEmpty {
                            Text("No instructions yet").foregroundStyle(.secondary)
                        }
                        ForEach(recipe.steps.indices, id: \.self) { index in
                            Text("\(index + 1). \(recipe.steps[index].text)")
                        }
                    }
                }
                .navigationTitle(recipe.title)
                .toolbar {
                    NavigationLink("Edit", destination: RecipeEditorView(recipeID: recipeID))
                }
            } else {
                ContentUnavailableView("Recipe unavailable", systemImage: "book.closed")
            }
        }
    }
}
