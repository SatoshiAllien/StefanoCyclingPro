import SwiftUI
import Charts

struct CadenceChartView: View {
    let samples: [MetricsSample]

    var body: some View {
        chartCard("Cadence") {
            Chart(samples.suffix(120)) { s in
                BarMark(x: .value("T", s.timestamp, unit: .second), y: .value("RPM", s.cadence))
                    .foregroundStyle(Theme.neonBlue.gradient)
            }
            .frame(height: 120)
        }
    }
}