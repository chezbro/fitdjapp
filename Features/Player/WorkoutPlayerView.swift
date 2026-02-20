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

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text(workout.title)
                .font(.title.bold())

            Text(formattedTime(timeRemaining))
                .font(.system(size: 48, weight: .bold, design: .monospaced))

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
                    showCompletion = true
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
            startTicker()
        }
        .onDisappear {
            tickTask?.cancel()
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

    private func startTicker() {
        tickTask?.cancel()
        tickTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                guard !isPaused, timeRemaining > 0 else { continue }
                await MainActor.run {
                    timeRemaining = max(0, timeRemaining - 1)
                }
            }
        }
    }

    private func togglePause() {
        isPaused.toggle()
    }

    private func skip(seconds: Int) {
        timeRemaining = max(0, timeRemaining - seconds)
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }
}
