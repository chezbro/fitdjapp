import SwiftUI

struct PaywallView: View {
    let products: [Product]
    let subscribe: (Product) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                Text("Unlock FITDJ Pro")
                    .font(.largeTitle.bold())

                Text("Train with adaptive music, guided coaching, and premium workout programs.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.fitdjMutedText)

                ForEach(products) { product in
                    Button(action: {
                        Haptics.tap()
                        subscribe(product)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(.headline)
                                Text("\(product.price) · \(product.freeTrialDays)-day free trial")
                                    .font(.subheadline)
                                    .foregroundColor(Color.fitdjMutedText)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .fitdjCard()
                    }
                    .buttonStyle(.plain)
                }

                Text("$14.99/month or $99/year after trial. Cancel anytime.")
                    .font(.footnote)
                    .foregroundColor(Color.fitdjMutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
        }
        .fitdjScreenBackground()
        .foregroundColor(.white)
    }
}
