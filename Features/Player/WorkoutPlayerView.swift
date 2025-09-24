import SwiftUI

struct WorkoutPlayerView: View {
    let workout: Workout
    let container: DependencyContainer
    @State private var timeRemaining: Int = 0
    @State private var isPaused = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Text(workout.title)
                .font(.title.bold())
            Text("Time Remaining: \(timeRemaining)s")
                .font(.largeTitle.monospacedDigit())
            Slider(value: .constant(0.5))
            HStack(spacing: 16) {
                Button(isPaused ? "Resume" : "Pause") { togglePause() }
                Button("Skip") {}
                Button("Easier") {}
                Button("Harder") {}
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.fitdjAccent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .onAppear {
            timeRemaining = workout.duration * 60
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private func togglePause() {
        isPaused.toggle()
    }
}
