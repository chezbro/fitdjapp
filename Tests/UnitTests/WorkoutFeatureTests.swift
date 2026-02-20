import XCTest
@testable import FITDJ

final class WorkoutFeatureTests: XCTestCase {
    func testGuidedDurationIncludesRest() {
        let block = WorkoutPhase.Block(branch: nil, exercise: "pushup", duration: 30, rest: 10, video: nil, cues: nil)
        let phase = WorkoutPhase(name: "Main", blocks: [block])
        let workout = Workout(
            id: "w1",
            title: "Test",
            duration: 10,
            level: .beginner,
            equipment: [.bodyweight],
            phases: [phase],
            music: .init(playlistAdminId: "x", bpmTarget: [120, 130], energy: [0.5, 0.8])
        )

        XCTAssertEqual(workout.guidedDurationSeconds, 40)
    }

    func testWorkoutFilteringByQueryAndLevel() {
        let beginner = Workout(
            id: "w1",
            title: "Beginner Burn",
            duration: 20,
            level: .beginner,
            equipment: [.bodyweight],
            phases: [],
            music: .init(playlistAdminId: "x", bpmTarget: [120, 130], energy: [0.5, 0.8])
        )
        let advanced = Workout(
            id: "w2",
            title: "Advanced Blast",
            duration: 25,
            level: .advanced,
            equipment: [.dumbbells],
            phases: [],
            music: .init(playlistAdminId: "y", bpmTarget: [130, 150], energy: [0.7, 0.9])
        )

        let filtered = WorkoutFiltering.apply(workouts: [beginner, advanced], query: "blast", level: .advanced)
        XCTAssertEqual(filtered.map(\.id), ["w2"])
    }
}
