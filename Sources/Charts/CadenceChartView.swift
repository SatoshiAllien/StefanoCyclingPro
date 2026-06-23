import SwiftUI
import Charts

struct CadenceChartView: View {
    let samples: [MetricsSample]

    var body: some View {
        chartCard("Cadence") {
            Chart(ChartThrottle.displaySamples(from: samples)) { s in
                BarMark(x: .value("T", s.timestamp, unit: .second), y: .value("RPM", s.cadence))
                    .foregroundStyle(Theme.neonBlue.gradient)
            }
            .frame(height: 120)
        }
    }
}