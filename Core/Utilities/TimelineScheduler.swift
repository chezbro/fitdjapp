import Foundation

actor TimelineScheduler {
    private var start: DispatchTime?

    func startNow() {
        start = .now()
    }

    func now() -> TimeInterval {
        guard let s = start else { return 0 }
        let diff = DispatchTime.now().uptimeNanoseconds - s.uptimeNanoseconds
        return TimeInterval(diff) / 1_000_000_000
    }

    func schedule(atOffset seconds: TimeInterval, _ action: @escaping () -> Void) async {
        Task { @MainActor in
            let ns = UInt64(max(0, seconds) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ns)
            action()
        }
    }
}
