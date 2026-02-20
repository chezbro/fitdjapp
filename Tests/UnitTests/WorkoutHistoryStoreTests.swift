import XCTest
@testable import FITDJ

final class WorkoutHistoryStoreTests: XCTestCase {
    func testSaveCompletionIncrementsWeeklyCount() {
        let defaults = UserDefaults(suiteName: "WorkoutHistoryStoreTests")!
        defaults.removePersistentDomain(forName: "WorkoutHistoryStoreTests")

        let store = WorkoutHistoryStore(defaults: defaults)
        XCTAssertEqual(store.weeklyStreakCount(), 0)

        store.saveCompletion(workoutId: "w1", workoutTitle: "Test", durationSeconds: 600)
        XCTAssertEqual(store.weeklyStreakCount(), 1)
    }
}
