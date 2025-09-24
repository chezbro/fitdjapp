import XCTest
@testable import FITDJ

final class TimelineSchedulerTests: XCTestCase {
    func testStartNowSetsTime() async throws {
        let scheduler = TimelineScheduler()
        await scheduler.startNow()
        let now = await scheduler.now()
        XCTAssertGreaterThanOrEqual(now, 0)
    }
}
