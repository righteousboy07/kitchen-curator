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
                RecipeDetailView(recipe: recipe)
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
    let recipe: KitchenRecipe

    var body: some View {
        List {
            if !recipe.ingredients.isEmpty {
                Section("Ingredients") {
                    ForEach(recipe.ingredients) { ingredient in
                        Text(ingredient.name)
                    }
                }
            }
            if !recipe.steps.isEmpty {
                Section("Directions") {
                    ForEach(recipe.steps.indices, id: \.self) { index in
                        Text("\(index + 1). \(recipe.steps[index].text)")
                    }
                }
            }
            if recipe.ingredients.isEmpty && recipe.steps.isEmpty {
                ContentUnavailableView("Recipe is empty", systemImage: "pencil", description: Text("Ingredient and instruction editing is coming next."))
            }
        }
        .navigationTitle(recipe.title)
    }
}
