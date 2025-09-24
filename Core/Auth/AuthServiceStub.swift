import Foundation

final class AuthServiceStub: AuthService {
    private var account: UserAccount?

    func signInWithApple() async throws -> UserAccount {
        let user = UserAccount(id: UUID().uuidString, name: "Demo Athlete")
        account = user
        return user
    }

    func currentUser() throws -> UserAccount? {
        account
    }
}
