import Foundation

@MainActor
final class WorkoutViewModel: ObservableObject {
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var isActive: Bool { appState.isWorkoutActive }
    var isPaused: Bool { appState.liveMetrics.isPaused }
    var elapsed: Int { appState.recorder.elapsedSeconds }
    var heartRate: Double { appState.liveMetrics.heartRate }
    var heartRateSource: HeartRateSource { appState.liveMetrics.heartRateSource }
    var heartRateSourceLabel: String { heartRateSource.displayName }
    var watchConnected: Bool { appState.watchHRConnected }
    var usingFallbackHR: Bool { heartRateSource != .appleWatch }

    func start() { appState.startWorkout() }
    func stop() { appState.stopWorkout() }

    var elapsedFormatted: String {
        let e = elapsed
        return String(format: "%02d:%02d", e / 60, e % 60)
    }
}