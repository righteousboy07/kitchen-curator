import SwiftUI

@main
struct KitchenCuratorApp: App {
    @StateObject private var recipeStore = RecipeStore()
    @StateObject private var playlistStore = PlaylistSourceStore()

    var body: some Scene {
        WindowGroup {
            KitchenCuratorRootView()
                .environmentObject(recipeStore)
                .environmentObject(playlistStore)
        }
    }
}
