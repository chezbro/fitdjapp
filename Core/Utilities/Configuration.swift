import Foundation

struct RemoteConfiguration {
    let elevenLabsKeyEndpoint: URL
    let spotifyTokenEndpoint: URL
    let firestoreProjectId: String

    static let stub = RemoteConfiguration(
        elevenLabsKeyEndpoint: URL(string: "https://api.example.com/fitdj/tts-token")!,
        spotifyTokenEndpoint: URL(string: "https://api.example.com/fitdj/spotify-token")!,
        firestoreProjectId: "fitdj-demo"
    )
}
