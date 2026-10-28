import SwiftUI

@main
struct KitchenCuratorApp: App {
    @StateObject private var recipeStore = RecipeStore()

    var body: some Scene {
        WindowGroup {
            KitchenCuratorRootView()
                .environmentObject(recipeStore)
        }
    }
}
