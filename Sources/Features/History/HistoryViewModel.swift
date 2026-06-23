import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    var workouts: [CyclingWorkout] { appState.workouts }
    private let appState: AppState
    init(appState: AppState) { self.appState = appState }
}