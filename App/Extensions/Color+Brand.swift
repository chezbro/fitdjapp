import SwiftUI

extension Color {
    private static func namedOrFallback(_ name: String, fallback: Color) -> Color {
        if let uiColor = UIColor(named: name, in: .main, compatibleWith: nil) {
            return Color(uiColor)
        }
        return fallback
    }

    static let fitdjBackground = namedOrFallback("Background", fallback: Color(red: 0.102, green: 0.129, blue: 0.318))
    static let fitdjAccent = namedOrFallback("Accent", fallback: Color(red: 1.0, green: 0.353, blue: 0.373))
    static let fitdjSurface = Color.white.opacity(0.07)
    static let fitdjMutedText = Color.white.opacity(0.68)
}
