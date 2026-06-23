import Foundation

struct WatchWorkoutModel: Codable, Hashable, Equatable {
    let heartRate: Double
    let avgHeartRate: Double
    let durationSeconds: Int
    let calories: Double
    let timestamp: Date

    init(
        heartRate: Double,
        avgHeartRate: Double = 0,
        durationSeconds: Int = 0,
        calories: Double = 0,
        timestamp: Date = Date()
    ) {
        self.heartRate = heartRate
        self.avgHeartRate = avgHeartRate
        self.durationSeconds = durationSeconds
        self.calories = calories
        self.timestamp = timestamp
    }

    static func == (lhs: WatchWorkoutModel, rhs: WatchWorkoutModel) -> Bool {
        lhs.heartRate == rhs.heartRate
            && lhs.avgHeartRate == rhs.avgHeartRate
            && lhs.durationSeconds == rhs.durationSeconds
            && lhs.calories == rhs.calories
            && lhs.timestamp.timeIntervalSince1970 == rhs.timestamp.timeIntervalSince1970
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(heartRate)
        hasher.combine(avgHeartRate)
        hasher.combine(durationSeconds)
        hasher.combine(calories)
        hasher.combine(timestamp.timeIntervalSince1970)
    }

    var dictionaryPayload: [String: Any] {
        [
            "heartRate": heartRate,
            "avgHeartRate": avgHeartRate,
            "durationSeconds": durationSeconds,
            "calories": calories,
            "timestamp": timestamp.timeIntervalSince1970
        ]
    }
}