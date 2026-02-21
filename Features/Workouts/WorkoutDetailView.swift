import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    let container: DependencyContainer
    @State private var showingPlayer = false
    @State private var isFavorite = false

    private var favoriteKey: String { "favorite_workout_\(workout.id)" }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text(workout.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration: \(workout.duration) minutes")
                    Text("Guided Time: \(workout.guidedDurationSeconds / 60)m \(workout.guidedDurationSeconds % 60)s")
                    Text("Equipment: \(workout.equipment.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                    Text("Level: \(workout.level.rawValue.capitalized)")
                }
                .foregroundColor(.white)
                .fitdjCard()

                ForEach(workout.phases) { phase in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(phase.name)
                            .font(.headline)
                        Text("\(phase.totalDurationSeconds)s total")
                            .font(.caption)
                            .foregroundColor(Color.fitdjMutedText)

                        ForEach(phase.blocks) { block in
                            HStack {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .foregroundColor(.white.opacity(0.85))
                                Text(block.exercise.replacingOccurrences(of: "_", with: " "))
                                    .font(.subheadline)
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .fitdjCard()
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .fitdjScreenBackground()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    Haptics.tap()
                    isFavorite.toggle()
                    UserDefaults.standard.set(isFavorite, forKey: favoriteKey)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                }

                Button("Start") {
                    Haptics.tap()
                    showingPlayer = true
                }
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
