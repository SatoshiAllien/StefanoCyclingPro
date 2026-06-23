import Foundation

@MainActor
final class WorkoutViewModel: ObservableObject {
    var isActive: Bool { appState.isWorkoutActive }
    var isPaused: Bool { appState.liveMetrics.isPaused }
    var elapsed: Int { appState.recorder.elapsedSeconds }
    var heartRate: Double { appState.liveMetrics.heartRate }
    var heartRateSourceLabel: String { appState.liveMetrics.heartRateSource.displayName }
    var watchConnected: Bool { appState.watchHRConnected }

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func start() { appState.startWorkout() }
    func stop() { appState.stopWorkout() }

    var elapsedFormatted: String {
        let e = elapsed
        return String(format: "%02d:%02d", e / 60, e % 60)
    }
}