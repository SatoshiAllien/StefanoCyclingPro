import Foundation

struct CyclingWorkout: Identifiable, Codable, Hashable, Equatable {
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

    static func == (lhs: CyclingWorkout, rhs: CyclingWorkout) -> Bool {
        lhs.id == rhs.id
            && lhs.startedAt.timeIntervalSince1970 == rhs.startedAt.timeIntervalSince1970
            && lhs.endedAt.timeIntervalSince1970 == rhs.endedAt.timeIntervalSince1970
            && lhs.durationSeconds == rhs.durationSeconds
            && lhs.distanceKm == rhs.distanceKm
            && lhs.avgPower == rhs.avgPower
            && lhs.maxPower == rhs.maxPower
            && lhs.normalizedPower == rhs.normalizedPower
            && lhs.avgCadence == rhs.avgCadence
            && lhs.avgSpeedKmh == rhs.avgSpeedKmh
            && lhs.avgHeartRate == rhs.avgHeartRate
            && lhs.calories == rhs.calories
            && lhs.elevationGainM == rhs.elevationGainM
            && lhs.zoneDistribution == rhs.zoneDistribution
            && lhs.samples == rhs.samples
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(startedAt.timeIntervalSince1970)
        hasher.combine(endedAt.timeIntervalSince1970)
        hasher.combine(durationSeconds)
        hasher.combine(distanceKm)
        hasher.combine(avgPower)
        hasher.combine(maxPower)
        hasher.combine(normalizedPower)
        hasher.combine(avgCadence)
        hasher.combine(avgSpeedKmh)
        hasher.combine(avgHeartRate)
        hasher.combine(calories)
        hasher.combine(elevationGainM)
        for key in zoneDistribution.keys.sorted() {
            hasher.combine(key)
            hasher.combine(zoneDistribution[key]!)
        }
        hasher.combine(samples)
    }
}