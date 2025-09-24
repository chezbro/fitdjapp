import Foundation

protocol DuckingCoordinator {
    func beginDuck(attack: TimeInterval, gainDB: Float)
    func endDuck(release: TimeInterval)
}

final class SpotifyDuckingCoordinator: DuckingCoordinator {
    private let musicService: MusicService

    init(musicService: MusicService) {
        self.musicService = musicService
    }

    func beginDuck(attack: TimeInterval, gainDB: Float) {
        musicService.setMusicDuck(level: gainDB, attack: attack, release: 0)
    }

    func endDuck(release: TimeInterval) {
        musicService.setMusicDuck(level: 0, attack: 0, release: release)
    }
}
