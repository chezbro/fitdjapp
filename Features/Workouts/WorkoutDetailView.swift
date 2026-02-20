import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    let container: DependencyContainer
    @State private var showingPlayer = false
    @State private var isFavorite = false

    private var favoriteKey: String { "favorite_workout_\(workout.id)" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(workout.title)
                    .font(.largeTitle.bold())
                Text("Duration: \(workout.duration) minutes")
                Text("Guided Time: \(workout.guidedDurationSeconds / 60)m \(workout.guidedDurationSeconds % 60)s")
                Text("Equipment: \(workout.equipment.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                Text("Level: \(workout.level.rawValue.capitalized)")
                Divider()
                ForEach(workout.phases) { phase in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(phase.name)
                            .font(.headline)
                        Text("\(phase.totalDurationSeconds)s total")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    isFavorite.toggle()
                    UserDefaults.standard.set(isFavorite, forKey: favoriteKey)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                }

                Button("Start") { showingPlayer = true }
            }
        }
        .sheet(isPresented: $showingPlayer) {
            WorkoutPlayerView(workout: workout, container: container)
        }
        .onAppear {
            isFavorite = UserDefaults.standard.bool(forKey: favoriteKey)
        }
    }
}
