import Foundation
import AVFoundation
import Combine

final class AudioEngineController: ObservableObject {
    private let engine = AVAudioEngine()
    private let voicePlayer = AVAudioPlayerNode()
    private let voiceMixer = AVAudioMixerNode()
    @Published var coachGain: Float = 0

    init() {
        engine.attach(voicePlayer)
        engine.attach(voiceMixer)
        engine.connect(voicePlayer, to: voiceMixer, format: nil)
        engine.connect(voiceMixer, to: engine.mainMixerNode, format: nil)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetoothA2DP])
        try? engine.start()
    }

    func playVoice(_ fileURL: URL, onStart: @escaping () -> Void, onEnd: @escaping () -> Void) {
        do {
            let file = try AVAudioFile(forReading: fileURL)
            voicePlayer.scheduleFile(file, at: nil) { onEnd() }
            onStart()
            voicePlayer.play()
        } catch {
            onStart()
            onEnd()
        }
    }
}
