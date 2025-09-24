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
        let deadline = DispatchTime.now() + seconds
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            action()
        }
        Task {
            try? await Task.sleep(until: deadline, clock: .continuous)
        }
    }
}
