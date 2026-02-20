import SwiftUI

struct HomeView: View {
    let container: DependencyContainer
    @State private var workouts: [Workout] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedLevel: WorkoutLevel?

    private var filteredWorkouts: [Workout] {
        WorkoutFiltering.apply(workouts: workouts, query: searchText, level: selectedLevel)
    }

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    List(filteredWorkouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout, container: container)) {
                            WorkoutRow(workout: workout)
                        }
                        .listRowBackground(Color.black)
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $searchText, prompt: "Search workouts")
                    .refreshable { await loadWorkouts() }
                }
            }
            .navigationTitle("Featured")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("All Levels") { selectedLevel = nil }
                        ForEach(WorkoutLevel.allCases) { level in
                            Button(level.rawValue.capitalized) {
                                selectedLevel = level
                            }
                        }
                    } label: {
                        Label(selectedLevel?.rawValue.capitalized ?? "All Levels", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }

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
        isLoading = true
        defer { isLoading = false }

        do {
            workouts = try await container.workoutRepository.fetchFeatured()
        } catch {
            workouts = []
        }
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
