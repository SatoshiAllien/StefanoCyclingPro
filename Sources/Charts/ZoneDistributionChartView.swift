import SwiftUI
import Charts

struct ZoneDistributionChartView: View {
    let distribution: [Int: Double]

    private var slices: [ZoneSlice] {
        PowerZone.allCases.compactMap { zone in
            let pct = distribution[zone.rawValue] ?? 0
            guard pct > 0 else { return nil }
            return ZoneSlice(zone: zone, percentage: pct)
        }
    }

    var body: some View {
        chartCard("Zone Distribution") {
            if slices.isEmpty {
                Text("Ride to collect zone data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 160)
            } else if #available(iOS 17.0, *) {
                zonePieChart
            } else {
                zoneBarChart
            }
        }
    }

    @available(iOS 17.0, *)
    private var zonePieChart: some View {
        Chart(slices) { slice in
            SectorMark(
                angle: .value("Time", slice.percentage),
                innerRadius: .ratio(0.55),
                angularInset: 1.5
            )
            .foregroundStyle(slice.zone.color)
            .cornerRadius(4)
        }
        .frame(height: 180)
        .animation(.easeInOut(duration: 0.4), value: slices.count)
    }

    private var zoneBarChart: some View {
        Chart(slices) { slice in
            BarMark(
                x: .value("Zone", slice.zone.label),
                y: .value("%", slice.percentage)
            )
            .foregroundStyle(slice.zone.color)
            .cornerRadius(4)
        }
        .chartYAxisLabel("% time")
        .frame(height: 180)
        .animation(.easeInOut(duration: 0.4), value: slices.count)
    }
}

private struct ZoneSlice: Identifiable {
    let zone: PowerZone
    let percentage: Double
    var id: Int { zone.rawValue }
}