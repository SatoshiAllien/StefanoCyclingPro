import SwiftUI
import Charts

struct SpeedChartView: View {
    let samples: [MetricsSample]

    var body: some View {
        chartCard("Speed") {
            Chart(samples.suffix(120)) { s in
                AreaMark(x: .value("T", s.timestamp), y: .value("km/h", s.speedKmh))
                    .foregroundStyle(Theme.neonPurple.opacity(0.4))
                LineMark(x: .value("T", s.timestamp), y: .value("km/h", s.speedKmh))
                    .foregroundStyle(Theme.neonPurple)
            }
            .frame(height: 120)
        }
    }
}

@ViewBuilder
func chartCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title).font(.headline)
        content()
    }
    .padding()
    .background(Theme.card)
    .clipShape(RoundedRectangle(cornerRadius: 16))
}