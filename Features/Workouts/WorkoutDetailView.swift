import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    let container: DependencyContainer
    @State private var showingPlayer = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(workout.title)
                    .font(.largeTitle.bold())
                Text("Duration: \(workout.duration) minutes")
                Text("Equipment: \(workout.equipment.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                Text("Level: \(workout.level.rawValue.capitalized)")
                Divider()
                ForEach(workout.phases) { phase in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(phase.name)
                            .font(.headline)
                        ForEach(phase.blocks) { block in
                            Text(block.exercise.replacingOccurrences(of: "_", with: " "))
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding()
            .foregroundColor(.white)
        }
        .background(Color.black.ignoresSafeArea())
        .toolbar {
            Button("Start") { showingPlayer = true }
        }
        .sheet(isPresented: $showingPlayer) {
            WorkoutPlayerView(workout: workout, container: container)
        }
    }
}
