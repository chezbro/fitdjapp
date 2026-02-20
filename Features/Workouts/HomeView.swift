import SwiftUI

struct HomeView: View {
    let container: DependencyContainer
    @State private var workouts: [Workout] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedLevel: WorkoutLevel?
    @State private var weeklyCompletions = 0
    @State private var animateHero = false

    private let historyStore = WorkoutHistoryStore()

    private var filteredWorkouts: [Workout] {
        WorkoutFiltering.apply(workouts: workouts, query: searchText, level: selectedLevel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.fitdjBackground, Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            headerCard
                            levelFilterRow

                            if let quick = filteredWorkouts.first {
                                NavigationLink(destination: WorkoutDetailView(workout: quick, container: container)) {
                                    quickStartCard(workout: quick)
                                }
                                .buttonStyle(.plain)
                            }

                            Text("Recommended")
                                .font(.title3.bold())
                                .foregroundColor(.white)

                            LazyVStack(spacing: 12) {
                                ForEach(filteredWorkouts) { workout in
                                    NavigationLink(destination: WorkoutDetailView(workout: workout, container: container)) {
                                        WorkoutRow(workout: workout)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    }
                    .refreshable {
                        await loadWorkouts()
                        refreshStats()
                    }
                }
            }
            .navigationTitle("Featured")
            .searchable(text: $searchText, prompt: "Search workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(container: container)) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .accentColor(Color.fitdjAccent)
        .task {
            await loadWorkouts()
            refreshStats()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                animateHero = true
            }
        }
    }

    private var headerCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("This week")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(weeklyCompletions)")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("workouts")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Text("Stay consistent. One more session keeps momentum high.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.72))
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 64, height: 64)

                Circle()
                    .trim(from: 0, to: animateHero ? min(1, Double(weeklyCompletions) / 7.0) : 0)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 64, height: 64)

                Text("\(min(weeklyCompletions, 7))")
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.fitdjAccent.opacity(0.45), Color.fitdjAccent.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var levelFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterPill(title: "All", isSelected: selectedLevel == nil) {
                    selectedLevel = nil
                }

                ForEach(WorkoutLevel.allCases) { level in
                    filterPill(
                        title: level.rawValue.capitalized,
                        isSelected: selectedLevel == level
                    ) {
                        selectedLevel = level
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func filterPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                action()
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(isSelected ? Color.white : Color.white.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.white.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func quickStartCard(workout: Workout) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 36, height: 36)
                .background(Color.white)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Quick Start")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.75))
                Text(workout.title)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            Spacer()

            Image(systemName: "arrow.right")
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func refreshStats() {
        weeklyCompletions = historyStore.weeklyStreakCount()
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
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.fitdjAccent.opacity(0.25))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "figure.run")
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(workout.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(workout.duration) min · \(workout.level.rawValue.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.68))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}
