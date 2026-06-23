import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    var metrics: LiveMetrics { appState.liveMetrics }
    var samples: [MetricsSample] { ChartThrottle.displaySamples(from: appState.chartSamples) }
    var watchConnected: Bool { appState.watchHRConnected }
    var heartRateSourceLabel: String { appState.liveMetrics.heartRateSource.displayName }
    var zoneDistribution: [Int: Double] {
        appState.calculator.zoneDistribution(samples: appState.chartSamples)
    }

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }
}