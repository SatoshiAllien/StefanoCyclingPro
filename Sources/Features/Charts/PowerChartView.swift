import SwiftUI
import Charts

struct PowerChartView: View {
    let samples: [MetricsSample]

    var body: some View {
        chartCard("Power") {
            Chart(ChartThrottle.displaySamples(from: samples)) { s in
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