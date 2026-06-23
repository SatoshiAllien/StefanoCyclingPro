import SwiftUI

#if os(watchOS)
struct WatchHRView: View {
    @EnvironmentObject var connectivity: WatchAppExtension
    @EnvironmentObject var hrSession: WatchHRSession

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(hrSession.isActive ? .red : .gray)
                .symbolEffect(.pulse, isActive: hrSession.isActive)

            Text(hrSession.heartRate > 0 ? String(format: "%.0f", hrSession.heartRate) : "—")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Theme.neonGreen)

            Text("BPM")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            Text(statusText)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(connectivity.isPhoneReachable ? Theme.neonBlue : .orange)

            if hrSession.isActive {
                let zone = PowerZone.zone(for: hrSession.heartRate)
                Text("Zone \(zone.rawValue)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(zone.color)
            }
        }
        .padding()
    }

    private var statusText: String {
        if hrSession.isActive { return "Streaming to iPhone" }
        if connectivity.isPhoneReachable { return "Ready — start workout on iPhone" }
        return "Open StefanoCyclingPro on iPhone"
    }
}
#endif