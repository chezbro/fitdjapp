import SwiftUI

struct WorkoutPlayerView: View {
    let workout: Workout
    let container: DependencyContainer

    @State private var timeRemaining: Int = 0
    @State private var isPaused = false
    @State private var showCompletion = false
    @State private var startedAt = Date()
    @State private var coachMix: Double = 0.5
    @State private var tickTask: Task<Void, Never>?

    @State private var sessionStatus = "Starting workout…"
    @State private var musicStatus = "Not playing"
    @State private var coachStatus = "Coach warming up"

    @State private var cueRotation: [VoiceCue] = []
    @State private var cueIndex = 0

    private let historyStore = WorkoutHistoryStore()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text(workout.title)
                .font(.title.bold())

            Text(formattedTime(timeRemaining))
                .font(.system(size: 48, weight: .bold, design: .monospaced))

            statusPills

            VStack(spacing: 8) {
                Slider(value: $coachMix, in: 0...1)
                Text("Coach Mix: \(Int(coachMix * 100))%")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                Button(isPaused ? "Resume" : "Pause") { togglePause() }
                Button("Skip -15s") { skip(seconds: 15) }
                Button("Easier") { coachMix = max(0, coachMix - 0.1) }
                Button("Harder") { coachMix = min(1, coachMix + 0.1) }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.fitdjAccent)

            if timeRemaining == 0 {
                Button("Finish Workout") {
                    finishWorkout()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .onAppear {
            startedAt = Date()
            timeRemaining = workout.guidedDurationSeconds
            configureCueRotation()
            startSession()
            startTicker()
        }
        .onDisappear {
            tickTask?.cancel()
            container.playbackController.stop()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
        .fullScreenCover(isPresented: $showCompletion) {
            CompletionView(workout: workout, duration: Date().timeIntervalSince(startedAt))
        }
    }

    private var statusPills: some View {
        VStack(spacing: 8) {
            Text("Workout: \(sessionStatus)")
            Text("Music: \(musicStatus)")
            Text("Coach: \(coachStatus)")
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }

    private func configureCueRotation() {
        cueRotation = workout.phases
            .flatMap { $0.blocks }
            .flatMap { block in
                (block.cues ?? []).map { cueText in
                    VoiceCue(
                        id: "\(workout.id)-\(UUID().uuidString)",
                        text: cueText,
                        type: .encouragement,
                        locale: "en-US",
                        prebundledAsset: nil
                    )
                }
            }
    }

    private func startSession() {
        Task {
            let session = WorkoutSession(
                workout: workout,
                startDate: startedAt,
                intensity: TrackCriteria(
                    bpm: workout.music.bpmTarget[0]...workout.music.bpmTarget[1],
                    energy: workout.music.energy[0]...workout.music.energy[1]
                )
            )

            do {
                try await container.playbackController.start(session)
                await MainActor.run { sessionStatus = "Active" }
            } catch {
                await MainActor.run { sessionStatus = "Playback degraded" }
            }

            do {
                try await container.musicService.authorize()
                let playlist = PlaylistBinding(
                    spotifyURI: "spotify:playlist:\(workout.music.playlistAdminId)",
                    defaultCriteria: session.intensity
                )
                try await container.musicService.startPlaylist(playlist)
                await MainActor.run { musicStatus = "Playing" }
            } catch {
                await MainActor.run { musicStatus = "Music unavailable" }
            }

            await container.voiceService.preload(cues: cueRotation)
            await speakNextCueIfAvailable()
        }
    }

    private func startTicker() {
        tickTask?.cancel()
        tickTask = Task {
            var secondsSinceCue = 0

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                guard !isPaused, timeRemaining > 0 else { continue }

                await MainActor.run {
                    timeRemaining = max(0, timeRemaining - 1)
                }
                secondsSinceCue += 1

                if secondsSinceCue >= 20 {
                    secondsSinceCue = 0
                    await speakNextCueIfAvailable()
                }
            }
        }
    }

    private func speakNextCueIfAvailable() async {
        guard !cueRotation.isEmpty else {
            await MainActor.run { coachStatus = "Ready" }
            return
        }

        let cue = cueRotation[cueIndex % cueRotation.count]
        cueIndex += 1
        await container.voiceService.speak(cue, deadline: nil)
        await MainActor.run { coachStatus = cue.text }
    }

    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            container.playbackController.pause()
            container.musicService.setMusicDuck(level: 0.2, attack: 0.2, release: 0.2)
            sessionStatus = "Paused"
        } else {
            container.playbackController.resume()
            container.musicService.setMusicDuck(level: Float(1 - coachMix), attack: 0.2, release: 0.2)
            sessionStatus = "Active"
        }
    }

    private func skip(seconds: Int) {
        timeRemaining = max(0, timeRemaining - seconds)
        Task { await container.musicService.nextTrack(matching: TrackCriteria(bpm: workout.music.bpmTarget[0]...workout.music.bpmTarget[1], energy: workout.music.energy[0]...workout.music.energy[1])) }
    }

    private func finishWorkout() {
        container.playbackController.stop()
        let elapsed = max(1, Int(Date().timeIntervalSince(startedAt)))
        historyStore.saveCompletion(workoutId: workout.id, workoutTitle: workout.title, durationSeconds: elapsed)
        showCompletion = true
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
}
