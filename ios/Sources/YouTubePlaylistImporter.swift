import Foundation

/// YouTube Data API v3 playlist metadata importer.
/// Requires an API key configured by the app owner; never bundle a private key
/// in a public repository or expose a server-side credential in the iOS app.
struct YouTubePlaylistImporter {
    let apiKey: String
    let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func videos(playlistID: String, maxPages: Int = 10) async throws -> [PlaylistVideo] {
        guard !apiKey.isEmpty else { throw ImportError.missingCredentials }
        guard !playlistID.isEmpty else { throw ImportError.invalidPlaylist }
        var pageToken: String?
        var videos: [PlaylistVideo] = []
        var seen = Set<String>()

        for _ in 0..<max(1, min(maxPages, 50)) {
            try Task.checkCancellation()
            var components = URLComponents(string: "https://www.googleapis.com/youtube/v3/playlistItems")!
            components.queryItems = [
                URLQueryItem(name: "part", value: "snippet"),
                URLQueryItem(name: "playlistId", value: playlistID),
                URLQueryItem(name: "maxResults", value: "50"),
                URLQueryItem(name: "key", value: apiKey)
            ]
            if let pageToken {
                components.queryItems?.append(URLQueryItem(name: "pageToken", value: pageToken))
            }
            var request = URLRequest(url: components.url!)
            request.timeoutInterval = 30
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw ImportError.invalidResponse }
            guard (200...299).contains(http.statusCode) else { throw ImportError.httpStatus(http.statusCode) }
            let page = try JSONDecoder().decode(PlaylistItemsPage.self, from: data)
            for item in page.items {
                guard let id = item.snippet.resourceId?.videoId,
                      !id.isEmpty, seen.insert(id).inserted else { continue }
                videos.append(PlaylistVideo(id: id, title: item.snippet.title, description: item.snippet.description ?? "",
                                          sourceURL: URL(string: "https://www.youtube.com/watch?v=\(id)")!))
            }
            guard let next = page.nextPageToken, !next.isEmpty else { break }
            pageToken = next
        }
        return videos
    }

    enum ImportError: LocalizedError {
        case missingCredentials, invalidPlaylist, invalidResponse, httpStatus(Int)
        var errorDescription: String? {
            switch self {
            case .missingCredentials: "YouTube API access has not been configured."
            case .invalidPlaylist: "Playlist ID is missing."
            case .invalidResponse: "YouTube returned an invalid response."
            case .httpStatus(let status): "YouTube request failed (HTTP \(status))."
            }
        }
    }
}

struct PlaylistVideo: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let sourceURL: URL
}

private struct PlaylistItemsPage: Decodable {
    let nextPageToken: String?
    let items: [Item]

    struct Item: Decodable {
        let snippet: Snippet
    }
    struct Snippet: Decodable {
        let title: String
        let description: String?
        let resourceId: ResourceID?
    }
    struct ResourceID: Decodable {
        let videoId: String?
    }
}
