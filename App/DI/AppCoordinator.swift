import SwiftUI
import Combine

final class AppCoordinator: ObservableObject {
    private let container: DependencyContainer
    @Published private var route: AppRoute = .launch

    init(container: DependencyContainer = DependencyContainer()) {
        self.container = container
        Task { await bootstrap() }
    }

    @ViewBuilder
    func rootView() -> some View {
        switch route {
        case .launch:
            LaunchView()
                .task { await bootstrap() }
        case .onboarding:
            OnboardingCoordinatorView(container: container) {
                await self.completeOnboarding()
            }
        case .home:
            HomeView(container: container)
        }
    }

    @MainActor
    private func bootstrap() async {
        let account = try? container.authService.currentUser()
        route = account != nil ? .home : .onboarding
    }

    @MainActor
    private func completeOnboarding() async {
        route = .home
    }
}

enum AppRoute {
    case launch
    case onboarding
    case home
}
