import Foundation

#if DEBUG
final class ElevenLabsVoiceServiceStub: VoiceService {
    func preload(cues: [VoiceCue]) async {}
    func speak(_ cue: VoiceCue, deadline: Date?) async {
        // TODO: Integrate ElevenLabs streaming
    }
}
#else
final class ElevenLabsVoiceServiceStub: VoiceService {
    func preload(cues: [VoiceCue]) async {}
    func speak(_ cue: VoiceCue, deadline: Date?) async {}
}
#endif
