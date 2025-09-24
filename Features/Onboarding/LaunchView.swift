import SwiftUI

struct LaunchView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Preparing FITDJ…")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .foregroundColor(.white)
    }
}
