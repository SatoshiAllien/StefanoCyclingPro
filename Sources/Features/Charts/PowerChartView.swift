import SwiftUI
import Charts

struct PowerChartView: View {
    let samples: [MetricsSample]

    var body: some View {
        chartCard("Power") {
            Chart(samples.suffix(120)) { s in
                LineMark(x: .value("T", s.timestamp), y: .value("W", s.power))
                    .foregroundStyle(Theme.neonGreen)
                    .interpolationMethod(.catmullRom)
            }
            .chartYAxisLabel("Watt")
            .frame(height: 160)
            .animation(.easeInOut(duration: 0.3), value: samples.count)
        }
    }
}