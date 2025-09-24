import Foundation

final class DependencyContainer {
    let workoutRepository: WorkoutRepository
    let playbackController: PlaybackController
    let voiceService: VoiceService
    let musicService: MusicService
    let authService: AuthService
    let paymentsService: PaymentsService
    let analyticsService: AnalyticsService

    init(
        workoutRepository: WorkoutRepository = WorkoutRepositoryFirestore(),
        playbackController: PlaybackController = DemoPlaybackController(),
        voiceService: VoiceService = ElevenLabsVoiceServiceStub(),
        musicService: MusicService = SpotifyMusicServiceStub(),
        authService: AuthService = AuthServiceStub(),
        paymentsService: PaymentsService = PaymentsServiceStub(),
        analyticsService: AnalyticsService = AnalyticsServiceStub()
    ) {
        self.workoutRepository = workoutRepository
        self.playbackController = playbackController
        self.voiceService = voiceService
        self.musicService = musicService
        self.authService = authService
        self.paymentsService = paymentsService
        self.analyticsService = analyticsService
    }
}
