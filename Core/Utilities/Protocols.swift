import Foundation

protocol WorkoutRepository {
    func fetchFeatured() async throws -> [Workout]
    func get(id: String) async throws -> Workout
}

protocol PlaybackController {
    func start(_ session: WorkoutSession) async throws
    func pause()
    func resume()
    func stop()
}

protocol VoiceService {
    func preload(cues: [VoiceCue]) async
    func speak(_ cue: VoiceCue, deadline: Date?) async
}

protocol MusicService {
    func authorize() async throws
    func startPlaylist(_ binding: PlaylistBinding) async throws
    func setMusicDuck(level: Float, attack: TimeInterval, release: TimeInterval)
    func nextTrack(matching: TrackCriteria) async
}

protocol AuthService {
    func signInWithApple() async throws -> UserAccount
    func currentUser() throws -> UserAccount?
}

protocol PaymentsService {
    func products() async throws -> [Product]
    func purchase(_ id: String) async throws
    var subscriptionEntitlements: AsyncStream<Bool> { get }
}

protocol AnalyticsService {
    func track(_ event: AnalyticsEvent)
}

struct Product: Identifiable {
    let id: String
    let title: String
    let price: String
    let freeTrialDays: Int
}
