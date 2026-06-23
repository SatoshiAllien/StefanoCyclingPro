import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    private let appState: AppState

    init(appState: AppState) { self.appState = appState }

    var workouts: [CyclingWorkout] { appState.workouts }

    func sampleCount(for workout: CyclingWorkout) -> Int {
        workout.samples.count
    }

    func zoneDistribution(for workout: CyclingWorkout) -> [Int: Double] {
        workout.zoneDistribution.dictionary
    }
}