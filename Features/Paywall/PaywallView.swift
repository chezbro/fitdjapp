import SwiftUI

struct PaywallView: View {
    let products: [Product]
    let subscribe: (Product) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Unlock FITDJ")
                .font(.largeTitle.bold())
            Text("Unlimited strength training with dynamic coaching and Spotify integration.")
                .multilineTextAlignment(.center)
            ForEach(products) { product in
                Button(action: { subscribe(product) }) {
                    VStack(alignment: .leading) {
                        Text(product.title)
                            .font(.headline)
                        Text("\(product.price) · \(product.freeTrialDays)-day free trial")
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.fitdjAccent)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            Text("$14.99/month or $99/year after free trial. Cancel anytime.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}
