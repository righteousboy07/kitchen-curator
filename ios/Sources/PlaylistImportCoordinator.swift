import Foundation
import Combine

/// Tracks import state separately from saved playlist URLs.
/// An API key must be supplied securely at runtime.
@MainActor
final class PlaylistImportCoordinator: ObservableObject {
    @Published private(set) var isImporting = false
    @Published private(set) var videos: [PlaylistVideo] = []
    @Published private(set) var status = "Ready to import"
    @Published private(set) var errorMessage: String?
    private var task: Task<Void, Never>?

    func start(playlistID: String, apiKey: String) {
        guard !isImporting else { return }
        isImporting = true
        errorMessage = nil
        status = "Fetching playlist videos…"
        task = Task {
            defer { isImporting = false; task = nil }
            do {
                let fetched = try await YouTubePlaylistImporter(apiKey: apiKey).videos(playlistID: playlistID)
                try Task.checkCancellation()
                videos = fetched
                status = "Found \(fetched.count) unique videos"
            } catch is CancellationError {
                status = "Import cancelled"
            } catch {
                errorMessage = error.localizedDescription
                status = "Import failed"
            }
        }
    }

    func cancel() {
        task?.cancel()
    }
}
