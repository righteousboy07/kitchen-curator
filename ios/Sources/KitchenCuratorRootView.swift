import SwiftUI

/// Native adaptive navigation shared by iPhone and iPad.
/// Width-class adaptation also responds to iPad multitasking windows.
struct KitchenCuratorRootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selection: KitchenSection = .recipes

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                TabView(selection: $selection) {
                    ForEach(KitchenSection.allCases) { section in
                        sectionContent(section)
                            .tabItem { Label(section.title, systemImage: section.symbol) }
                            .tag(section)
                    }
                }
            } else {
                NavigationSplitView {
                    List(selection: $selection) {
                        ForEach(KitchenSection.allCases) { section in
                            Label(section.title, systemImage: section.symbol)
                                .tag(section)
                        }
                    }
                    .listStyle(.sidebar)
                    .navigationTitle("Kitchen Curator")
                } detail: {
                    sectionContent(selection)
                }
                .navigationSplitViewStyle(.balanced)
            }
        }
    }

    @ViewBuilder
    private func sectionContent(_ section: KitchenSection) -> some View {
        NavigationStack {
            if section == .recipes {
                RecipeLibraryView()
                    .navigationTitle(section.title)
            } else {
                ContentUnavailableView(
                    section.title,
                    systemImage: section.symbol,
                    description: Text("This feature is under development.")
                )
                .navigationTitle(section.title)
            }
        }
    }
}

enum KitchenSection: String, CaseIterable, Identifiable, Hashable {
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
