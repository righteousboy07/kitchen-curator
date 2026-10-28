import SwiftUI

/// A native SwiftUI entry point for the iPhone and iPad companion app.
/// Add this file and KitchenCuratorRootView.swift to an iOS App target in Xcode.
@main
struct KitchenCuratorApp: App {
    var body: some Scene {
        WindowGroup {
            KitchenCuratorRootView()
        }
    }
}
