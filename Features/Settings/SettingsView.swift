import SwiftUI

struct SettingsView: View {
    let container: DependencyContainer
    @State private var captionsEnabled = true
    @State private var products: [Product] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Settings")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                audioSection
                accountSection
                subscriptionSection
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .fitdjScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.fitdjAccent)
        .task { await loadProducts() }
    }

    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Audio")
                .font(.headline)

            Toggle("Captions", isOn: $captionsEnabled)
                .tint(Color.fitdjAccent)

            Button("Connect Spotify") {
                Haptics.tap()
                Task { try? await container.musicService.authorize() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.fitdjAccent)
        }
        .foregroundColor(.white)
        .fitdjCard()
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(.headline)

            Button("Sign in with Apple") {
                Haptics.tap()
                Task { _ = try? await container.authService.signInWithApple() }
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
        .foregroundColor(.white)
        .fitdjCard()
    }

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subscription")
                .font(.headline)

            if products.isEmpty {
                Text("Loading plans…")
                    .foregroundColor(Color.fitdjMutedText)
            } else {
                ForEach(products) { product in
                    Button {
                        Haptics.tap()
                        Task { try? await container.paymentsService.purchase(product.id) }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(.subheadline.bold())
                                Text(product.price)
                                    .font(.caption)
                                    .foregroundColor(Color.fitdjMutedText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 4)
                }
            }
        }
        .foregroundColor(.white)
        .fitdjCard()
    }

    private func loadProducts() async {
        products = (try? await container.paymentsService.products()) ?? []
    }
}
