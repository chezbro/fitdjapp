import SwiftUI

struct LaunchView: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "bolt.heart.fill")
                .font(.system(size: 48))
                .foregroundColor(Color.fitdjAccent)
                .scaleEffect(animate ? 1.06 : 0.94)

            ProgressView()
                .tint(.white)

            Text("Preparing your training environment…")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fitdjScreenBackground()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
