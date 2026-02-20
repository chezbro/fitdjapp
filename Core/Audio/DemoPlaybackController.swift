import Foundation

final class DemoPlaybackController: PlaybackController {
    private var scheduler = TimelineScheduler()

    func start(_ session: WorkoutSession) async throws {
        await scheduler.startNow()
        // TODO: Bind to real playback engine
    }

    func pause() {}

    func resume() {}

    func stop() {}
}
