import SwiftUI

struct ZoneIndicator: View {
    let zone: PowerZone
    let heartRate: Double

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(zone.color)
                .frame(width: 14, height: 14)
                .shadow(color: zone.color.opacity(0.6), radius: 6)
            VStack(alignment: .leading, spacing: 2) {
                Text("Zone \(zone.rawValue) · \(zone.name)")
                    .font(.subheadline.weight(.semibold))
                Text(heartRate > 0 ? String(format: "%.0f bpm", heartRate) : "— bpm")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(zone.label)
                .font(.title2.bold())
                .foregroundStyle(zone.color)
        }
        .padding()
        .background(zone.color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(zone.color.opacity(0.3)))
        .animation(.easeInOut(duration: 0.3), value: zone)
    }
}