import SwiftUI

struct HRSourceIndicator: View {
    let source: HeartRateSource
    let isWatchReachable: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 8, height: 8)
                .shadow(color: indicatorColor.opacity(0.5), radius: 4)
            Text("HR Source: \(source.displayName)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Theme.card)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Theme.border))
    }

    private var indicatorColor: Color {
        switch source {
        case .appleWatch: return Theme.neonGreen
        case .ble: return Theme.neonBlue
        case .healthKit: return Theme.neonPurple
        case .unknown: return isWatchReachable ? .orange : .gray
        }
    }
}