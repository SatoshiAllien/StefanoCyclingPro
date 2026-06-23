import Foundation

final class StorageService {
    private let key = "stefano_cycling_workouts"

    func loadWorkouts() -> [CyclingWorkout] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([CyclingWorkout].self, from: data) else {
            return []
        }
        return items
    }

    func saveWorkouts(_ workouts: [CyclingWorkout]) {
        if let data = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}