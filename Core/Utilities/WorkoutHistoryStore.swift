import Foundation

struct WorkoutCompletion: Codable, Identifiable {
    let id: UUID
    let workoutId: String
    let workoutTitle: String
    let completedAt: Date
    let durationSeconds: Int
}

final class WorkoutHistoryStore {
    private let key = "fitdj_workout_history"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func saveCompletion(workoutId: String, workoutTitle: String, durationSeconds: Int) {
        var all = completions()
        all.insert(
            WorkoutCompletion(
                id: UUID(),
                workoutId: workoutId,
                workoutTitle: workoutTitle,
                completedAt: Date(),
                durationSeconds: durationSeconds
            ),
            at: 0
        )
        if all.count > 100 { all = Array(all.prefix(100)) }
        if let data = try? JSONEncoder().encode(all) {
            defaults.set(data, forKey: key)
        }
    }

    func completions() -> [WorkoutCompletion] {
        guard let data = defaults.data(forKey: key),
              let items = try? JSONDecoder().decode([WorkoutCompletion].self, from: data)
        else { return [] }
        return items
    }

    func weeklyStreakCount(reference: Date = Date()) -> Int {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: reference)?.start else { return 0 }
        return completions().filter { $0.completedAt >= startOfWeek }.count
    }
}
