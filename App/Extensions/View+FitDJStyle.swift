import SwiftUI

struct FitDJCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.fitdjSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

extension View {
    func fitdjCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(FitDJCardModifier(cornerRadius: cornerRadius))
    }

    func fitdjScreenBackground() -> some View {
        background(
            LinearGradient(
                colors: [Color.fitdjBackground, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
