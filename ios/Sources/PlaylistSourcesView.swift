import SwiftUI

struct PlaylistSourcesView: View {
    @EnvironmentObject private var sources: PlaylistSourceStore
    @State private var playlistURL = ""

    var body: some View {
        Form {
            Section {
                TextField("Paste YouTube playlist URL", text: $playlistURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .accessibilityLabel("YouTube playlist URL")
                Button("Save Playlist", systemImage: "plus") {
                    sources.add(playlistURL)
                    if sources.errorMessage == nil { playlistURL = "" }
                }
                .disabled(playlistURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } header: {
                Text("Recipe playlists")
            } footer: {
                Text("Saved playlists are ready for a future importer. Saving a URL does not download or analyze its videos.")
            }

            Section("Saved Playlists") {
                if sources.sources.isEmpty {
                    Text("No playlists added yet.")
                        .foregroundStyle(.secondary)
                }
                ForEach(sources.sources) { source in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(source.playlistID).font(.headline)
                        Text(source.url.absoluteString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
                .onDelete(perform: sources.delete)
            }
        }
        .navigationTitle("Playlist Sources")
        .alert("Playlist Issue", isPresented: Binding(
            get: { sources.errorMessage != nil },
            set: { _ in sources.clearError() }
        )) {
            Button("OK", role: .cancel) { sources.clearError() }
        } message: {
            Text(sources.errorMessage ?? "")
        }
    }
}
