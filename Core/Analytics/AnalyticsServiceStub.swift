import Foundation

final class AnalyticsServiceStub: AnalyticsService {
    func track(_ event: AnalyticsEvent) {
        print("Analytics event: \(event.name)")
    }
}
