import Foundation

struct CyclingWorkout: Identifiable, Codable, Hashable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date
    let durationSeconds: Int
    let distanceKm: Double
    let avgPower: Double
    let maxPower: Double
    let normalizedPower: Double
    let avgCadence: Double
    let avgSpeedKmh: Double
    let avgHeartRate: Double
    let calories: Double
    let elevationGainM: Double
    let zoneDistribution: [Int: Double]
    let samples: [MetricsSample]

    var durationFormatted: String {
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        let h = m / 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m % 60, s) : String(format: "%02d:%02d", m, s)
    }
}