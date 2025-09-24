import SwiftUI

@main
struct FITDJApp: App {
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            appCoordinator.rootView()
                .environmentObject(appCoordinator)
        }
    }
}
