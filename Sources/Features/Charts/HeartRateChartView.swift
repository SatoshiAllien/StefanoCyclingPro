import SwiftUI
import Charts

struct HeartRateChartView: View {
    let samples: [MetricsSample]

    var body: some View {
        chartCard("Heart Rate") {
            Chart(samples.suffix(120)) { s in
                LineMark(x: .value("T", s.timestamp), y: .value("BPM", s.heartRate))
                    .foregroundStyle(Color(hex: "FF3D00"))
                    .interpolationMethod(.catmullRom)
            }
            .chartYAxisLabel("bpm")
            .frame(height: 140)
        }
    }
}