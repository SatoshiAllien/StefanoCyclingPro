import SwiftUI

enum Theme {
    static let neonGreen = Color(hex: "00E676")
    static let neonBlue = Color(hex: "00B0FF")
    static let neonPurple = Color(hex: "AA00FF")
    static let background = Color(hex: "0A0A0F")
    static let card = Color(hex: "14141F")
    static let border = Color.white.opacity(0.08)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255
        )
    }
}