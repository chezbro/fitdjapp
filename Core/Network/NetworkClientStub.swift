import Foundation

final class NetworkClientStub {
    func get(_ url: URL) async throws -> Data {
        // TODO: Replace with real network stack
        return Data()
    }
}
