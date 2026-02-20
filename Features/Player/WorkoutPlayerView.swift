import SwiftUI

private struct NowPlayingTrack {
    let title: String
    let artist: String
    let bpm: Int
    let energy: Double
}

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
    @State private var transcript: [String] = []

    @State private var mockTracks: [NowPlayingTrack] = []
    @State private var currentTrackIndex = 0

    @State private var completionInsights: WorkoutInsights?

    private let historyStore = WorkoutHistoryStore()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                topHeader
                timerCard
                statusPills
                nowPlayingCard
                coachMixCard
                primaryControls
                transcriptCard
                finishButton
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                colors: [Color.fitdjBackground, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .foregroundColor(.white)
        .onAppear {
            startedAt = Date()
            timeRemaining = workout.guidedDurationSeconds
            configureCueRotation()
            configureMockTracks()
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
                    .foregroundColor(.white)
            }
        }
        .fullScreenCover(isPresented: $showCompletion) {
            CompletionView(
                workout: workout,
                duration: Date().timeIntervalSince(startedAt),
                insights: completionInsights
            )
        }
    }

    private var topHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .font(.title2.bold())
                Text("Guided Session")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var timerCard: some View {
        VStack(spacing: 10) {
            Text(formattedTime(timeRemaining))
                .font(.system(size: 60, weight: .heavy, design: .rounded))

            ProgressView(value: progressValue)
                .tint(Color.fitdjAccent)

            Text(isPaused ? "Paused" : "In Progress")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var progressValue: Double {
        let total = max(1, workout.guidedDurationSeconds)
        let elapsed = total - timeRemaining
        return min(1, max(0, Double(elapsed) / Double(total)))
    }

    private var statusPills: some View {
        VStack(spacing: 10) {
            statusPill(icon: "figure.run", title: "Workout", value: sessionStatus)
            statusPill(icon: "music.note", title: "Music", value: musicStatus)
            statusPill(icon: "waveform", title: "Coach", value: coachStatus)
        }
    }

    private func statusPill(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.75))
            Spacer()
            Text(value)
                .font(.footnote)
                .lineLimit(1)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.07))
        .clipShape(Capsule())
    }

    private var nowPlayingCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Now Playing")
                .font(.headline)

            if let track = currentTrack {
                Text(track.title)
                    .font(.title3.bold())
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))

                HStack(spacing: 10) {
                    chip(text: "\(track.bpm) BPM")
                    chip(text: "Energy \(Int(track.energy * 100))%")
                }
            } else {
                Text("No track selected")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func chip(text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.fitdjAccent.opacity(0.35))
            .clipShape(Capsule())
    }

    private var coachMixCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Coach Mix")
                    .font(.headline)
                Spacer()
                Text("\(Int(coachMix * 100))%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.85))
            }

            Slider(value: $coachMix, in: 0...1)
                .tint(Color.fitdjAccent)
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var primaryControls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                actionButton(isPaused ? "Resume" : "Pause", systemImage: isPaused ? "play.fill" : "pause.fill") {
                    togglePause()
                }

                actionButton("Skip 15s", systemImage: "goforward.15") {
                    skip(seconds: 15)
                }

                actionButton("Next", systemImage: "forward.fill") {
                    nextTrack()
                }
            }

            HStack(spacing: 10) {
                actionButton("Easier", systemImage: "minus.circle") {
                    coachMix = max(0, coachMix - 0.1)
                }

                actionButton("Harder", systemImage: "plus.circle") {
                    coachMix = min(1, coachMix + 0.1)
                }
            }
        }
    }

    private func actionButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var transcriptCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trainer Transcript")
                .font(.headline)

            if transcript.isEmpty {
                Text("No coach lines yet.")
                    .foregroundColor(.white.opacity(0.7))
            } else {
                ForEach(Array(transcript.suffix(5).enumerated()), id: \.offset) { _, line in
                    Text("• \(line)")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var finishButton: some View {
        if timeRemaining == 0 {
            Button("Finish Workout") {
                finishWorkout()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.fitdjAccent)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var currentTrack: NowPlayingTrack? {
        guard !mockTracks.isEmpty else { return nil }
        return mockTracks[currentTrackIndex % mockTracks.count]
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

    private func configureMockTracks() {
        let lowBPM = Int(workout.music.bpmTarget[0])
        let highBPM = Int(workout.music.bpmTarget[1])
        let lowEnergy = workout.music.energy[0]
        let highEnergy = workout.music.energy[1]

        mockTracks = [
            NowPlayingTrack(title: "Drive Mode", artist: "FITDJ Radio", bpm: lowBPM, energy: lowEnergy),
            NowPlayingTrack(title: "Rep Flow", artist: "Coach Mix", bpm: (lowBPM + highBPM) / 2, energy: (lowEnergy + highEnergy) / 2),
            NowPlayingTrack(title: "Last Set Push", artist: "Workout Sound", bpm: highBPM, energy: highEnergy)
        ]
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
                await MainActor.run {
                    musicStatus = "Playing"
                    currentTrackIndex = 0
                }
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
            var secondsSinceTrack = 0

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                guard !isPaused, timeRemaining > 0 else { continue }

                await MainActor.run {
                    timeRemaining = max(0, timeRemaining - 1)
                }
                secondsSinceCue += 1
                secondsSinceTrack += 1

                if secondsSinceCue >= 20 {
                    secondsSinceCue = 0
                    await speakNextCueIfAvailable()
                }

                if secondsSinceTrack >= 30 {
                    secondsSinceTrack = 0
                    await MainActor.run { nextTrack() }
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

        await MainActor.run {
            coachStatus = cue.text
            transcript.append(cue.text)
        }
    }

    private func nextTrack() {
        guard !mockTracks.isEmpty else { return }
        currentTrackIndex = (currentTrackIndex + 1) % mockTracks.count
        if let track = currentTrack {
            musicStatus = "Playing · \(track.title)"
        }

        Task {
            await container.musicService.nextTrack(
                matching: TrackCriteria(
                    bpm: workout.music.bpmTarget[0]...workout.music.bpmTarget[1],
                    energy: workout.music.energy[0]...workout.music.energy[1]
                )
            )
        }
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
        nextTrack()
    }

    private func finishWorkout() {
        container.playbackController.stop()
        let elapsed = max(1, Int(Date().timeIntervalSince(startedAt)))
        historyStore.saveCompletion(workoutId: workout.id, workoutTitle: workout.title, durationSeconds: elapsed)

        completionInsights = WorkoutInsights(
            weeklyCompletions: historyStore.weeklyStreakCount(),
            totalCompletions: historyStore.totalCompletions(),
            bestWorkoutSeconds: historyStore.bestDuration(for: workout.id),
            averageWorkoutSeconds: historyStore.averageDuration(for: workout.id),
            estimatedCalories: estimateCalories(elapsedSeconds: elapsed)
        )

        showCompletion = true
    }

    private func estimateCalories(elapsedSeconds: Int) -> Int {
        let minutes = Double(elapsedSeconds) / 60.0
        return max(40, Int(minutes * 8.5))
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
}
