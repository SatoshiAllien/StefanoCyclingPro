import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var metrics: LiveMetrics { appState.liveMetrics }
    var samples: [MetricsSample] { ChartThrottle.displaySamples(from: appState.chartSamples) }
    var watchConnected: Bool { appState.watchHRConnected }
    var heartRateSource: HeartRateSource { appState.liveMetrics.heartRateSource }
    var heartRateSourceLabel: String { heartRateSource.displayName }

    /// HR priority: Watch → BLE → HealthKit (resolved in AppState/MetricsMerger).
    var activeHeartRate: Double { appState.liveMetrics.heartRate }

    var zoneDistribution: [Int: Double] {
        appState.calculator.zoneDistribution(samples: appState.chartSamples)
    }

    var fallbackActive: Bool {
        heartRateSource == .healthKit || heartRateSource == .ble
    }
}