import SwiftUI

/// Adaptive shell for a universal iPhone and iPad application.
/// Integrate this view into the Xcode target when the native app is added.
struct KitchenCuratorRootView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selection: KitchenSection = .recipes

    var body: some View {
        Group {
            if sizeClass == .compact {
                TabView(selection: $selection) {
                    ForEach(KitchenSection.allCases) { section in
                        sectionContent(section)
                            .tabItem {
                                Label(section.title, systemImage: section.symbol)
                            }
                            .tag(section)
                    }
                }
            } else {
                NavigationSplitView {
                    List(KitchenSection.allCases, selection: $selection) { section in
                        Label(section.title, systemImage: section.symbol)
                            .tag(section)
                    }
                    .navigationTitle("Kitchen Curator")
                } detail: {
                    sectionContent(selection)
                }
            }
        }
    }

    @ViewBuilder
    private func sectionContent(_ section: KitchenSection) -> some View {
        NavigationStack {
            ContentUnavailableView(
                section.title,
                systemImage: section.symbol,
                description: Text("The \(section.title.lowercased()) screen will be connected to the recipe store.")
            )
            .navigationTitle(section.title)
        }
    }
}

enum KitchenSection: String, CaseIterable, Identifiable {
    case recipes, cooking, shopping, planning
    var id: Self { self }
    var title: String {
        switch self {
        case .recipes: "Recipes"
        case .cooking: "Cooking"
        case .shopping: "Shopping"
        case .planning: "Meal Plan"
        }
    }
    var symbol: String {
        switch self {
        case .recipes: "books.vertical"
        case .cooking: "frying.pan"
        case .shopping: "cart"
        case .planning: "calendar"
        }
    }
}
