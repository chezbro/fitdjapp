import SwiftUI

struct SettingsView: View {
    let container: DependencyContainer
    @State private var captionsEnabled = true
    @State private var products: [Product] = []

    var body: some View {
        Form {
            Section("Audio") {
                Toggle("Captions", isOn: $captionsEnabled)
                Button("Connect Spotify") {
                    Task { try? await container.musicService.authorize() }
                }
            }
            Section("Account") {
                Button("Sign in with Apple") {
                    Task { _ = try? await container.authService.signInWithApple() }
                }
            }
            Section("Subscription") {
                if products.isEmpty {
                    Text("Loading products…")
                } else {
                    ForEach(products) { product in
                        Button("Subscribe to \(product.title) – \(product.price)") {
                            Task { try? await container.paymentsService.purchase(product.id) }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .foregroundColor(.white)
        .navigationTitle("Settings")
        .tint(Color.fitdjAccent)
        .task { await loadProducts() }
    }

    private func loadProducts() async {
        products = (try? await container.paymentsService.products()) ?? []
    }
}
