import Foundation

final class CueScheduler {
    private let timeline: TimelineScheduler
    private let voice: VoiceService
    private let duck: DuckingCoordinator

    init(timeline: TimelineScheduler, voice: VoiceService, duck: DuckingCoordinator) {
        self.timeline = timeline
        self.voice = voice
        self.duck = duck
    }

    func schedule(cue: VoiceCue, at offset: TimeInterval) {
        Task {
            await timeline.schedule(atOffset: offset) { [weak self] in
                guard let self else { return }
                Task {
                    let deadline = Date().addingTimeInterval(0.3)
                    self.duck.beginDuck(attack: 0.3, gainDB: -12)
                    await self.voice.speak(cue, deadline: deadline)
                    self.duck.endDuck(release: 0.3)
                }
            }
        }
    }
}
