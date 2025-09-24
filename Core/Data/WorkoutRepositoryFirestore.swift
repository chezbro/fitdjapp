import Foundation

final class WorkoutRepositoryFirestore: WorkoutRepository {
    private let loader: SeedDataLoader

    init(loader: SeedDataLoader = SeedDataLoader()) {
        self.loader = loader
    }

    func fetchFeatured() async throws -> [Workout] {
        return try await loader.loadWorkouts()
    }

    func get(id: String) async throws -> Workout {
        let workouts = try await loader.loadWorkouts()
        guard let workout = workouts.first(where: { $0.id == id }) else {
            throw NSError(domain: "fitdj", code: 404)
        }
        return workout
    }
}

final class SeedDataLoader {
    func loadWorkouts() async throws -> [Workout] {
        let url = Bundle.main.url(forResource: "workouts", withExtension: "json", subdirectory: "Seeds")
        let data = try Data(contentsOf: url ?? URL(fileURLWithPath: "Seeds/workouts.json"))
        let decoder = JSONDecoder()
        return try decoder.decode([Workout].self, from: data)
    }
}
