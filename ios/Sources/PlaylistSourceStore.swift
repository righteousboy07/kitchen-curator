import Foundation
import Combine

/// Stores playlist sources without fetching video data.
/// Actual imports require a separately implemented, authorized provider.
@MainActor
final class PlaylistSourceStore: ObservableObject {
    @Published private(set) var sources: [PlaylistSource] = []
    @Published private(set) var errorMessage: String?

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        self.fileURL = fileURL ?? support.appendingPathComponent("KitchenCurator/playlists.json")
        load()
    }

    func clearError() { errorMessage = nil }

    func add(_ rawURL: String) {
        errorMessage = nil
        guard let url = URL(string: rawURL.trimmingCharacters(in: .whitespacesAndNewlines)),
              let host = url.host?.lowercased(),
              ["youtube.com", "www.youtube.com", "m.youtube.com", "music.youtube.com"].contains(host),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let playlistID = components.queryItems?.first(where: { $0.name == "list" })?.value,
              !playlistID.isEmpty else {
            errorMessage = "Enter a valid YouTube playlist URL containing a list ID."
            return
        }

        guard !sources.contains(where: { $0.playlistID == playlistID }) else {
            errorMessage = "That playlist is already saved."
            return
        }

        let old = sources
        sources.append(PlaylistSource(id: UUID(), playlistID: playlistID, url: url, addedAt: Date()))
        if !save() { sources = old }
    }

    func delete(at offsets: IndexSet) {
        let old = sources
        sources.remove(atOffsets: offsets)
        if !save() { sources = old }
    }

    private func load() {
        do {
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            sources = try decoder.decode([PlaylistSource].self, from: Data(contentsOf: fileURL))
            errorMessage = nil
        } catch {
            errorMessage = "Could not load playlist sources: \(error.localizedDescription)"
        }
    }

    @discardableResult
    private func save() -> Bool {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            try encoder.encode(sources).write(to: fileURL, options: .atomic)
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Could not save playlist sources: \(error.localizedDescription)"
            return false
        }
    }
}

struct PlaylistSource: Codable, Identifiable {
    let id: UUID
    let playlistID: String
    let url: URL
    let addedAt: Date
}
