import Foundation

final class SpotifyMusicServiceStub: MusicService {
    private var authorized = false

    func authorize() async throws {
        authorized = true
    }

    func startPlaylist(_ binding: PlaylistBinding) async throws {
        guard authorized else { throw NSError(domain: "fitdj", code: 401) }
        // TODO: Bind to Spotify SDK
    }

    func setMusicDuck(level: Float, attack: TimeInterval, release: TimeInterval) {
        // TODO: send duck to Spotify SDK
    }

    func nextTrack(matching: TrackCriteria) async {
        // TODO: request next track based on criteria
    }
}
