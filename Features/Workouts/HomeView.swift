import SwiftUI

struct HomeView: View {
    let container: DependencyContainer
    @State private var workouts: [Workout] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    List(workouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout, container: container)) {
                            WorkoutRow(workout: workout)
                        }
                        .listRowBackground(Color.black)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Featured")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(container: container)) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .accentColor(Color.fitdjAccent)
        .task { await loadWorkouts() }
    }

    private func loadWorkouts() async {
        do {
            workouts = try await container.workoutRepository.fetchFeatured()
        } catch {
            workouts = []
        }
        isLoading = false
    }
}

private struct WorkoutRow: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.title)
                .font(.headline)
                .foregroundColor(.white)
            Text("\(workout.duration) min · \(workout.level.rawValue.capitalized)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
