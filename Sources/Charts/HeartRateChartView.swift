import SwiftUI
import Charts

struct HeartRateChartView: View {
    let samples: [MetricsSample]

    var body: some View {
        chartCard("Heart Rate") {
            Chart(ChartThrottle.displaySamples(from: samples)) { s in
                LineMark(x: .value("T", s.timestamp), y: .value("BPM", s.heartRate))
                    .foregroundStyle(Color(hex: "FF3D00"))
                    .interpolationMethod(.catmullRom)
            }
            .chartYAxisLabel("bpm")
            .frame(height: 140)
        }
    }
}