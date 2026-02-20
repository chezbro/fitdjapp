import Foundation

struct WorkoutFiltering {
    static func apply(
        workouts: [Workout],
        query: String,
        level: WorkoutLevel?
    ) -> [Workout] {
        workouts.filter { workout in
            let matchesQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || workout.title.localizedCaseInsensitiveContains(query)
            let matchesLevel = level == nil || workout.level == level
            return matchesQuery && matchesLevel
        }
    }
}
