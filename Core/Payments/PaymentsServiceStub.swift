import Foundation

final class PaymentsServiceStub: PaymentsService {
    private let entitlementContinuation: AsyncStream<Bool>.Continuation
    let subscriptionEntitlements: AsyncStream<Bool>

    init() {
        var continuation: AsyncStream<Bool>.Continuation!
        self.subscriptionEntitlements = AsyncStream { cont in
            continuation = cont
        }
        self.entitlementContinuation = continuation
        entitlementContinuation.yield(true)
    }

    func products() async throws -> [Product] {
        return [
            Product(id: "fitdj.monthly", title: "FITDJ Monthly", price: "$14.99", freeTrialDays: 7),
            Product(id: "fitdj.annual", title: "FITDJ Annual", price: "$99.00", freeTrialDays: 7)
        ]
    }

    func purchase(_ id: String) async throws {
        entitlementContinuation.yield(true)
    }
}
