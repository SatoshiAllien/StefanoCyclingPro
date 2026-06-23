import Foundation

/// Hashable zone map backed by parallel arrays (avoids `[Int: Double]` synthesis issues).
struct ZoneDistribution: Codable {
    let zones: [Int]
    let percentages: [Double]

    init(_ dictionary: [Int: Double] = [:]) {
        let sorted = dictionary.keys.sorted()
        zones = sorted
        percentages = sorted.map { dictionary[$0] ?? 0 }
    }

    var dictionary: [Int: Double] {
        Dictionary(uniqueKeysWithValues: zip(zones, percentages))
    }
}

extension ZoneDistribution: Equatable {
    static func == (lhs: ZoneDistribution, rhs: ZoneDistribution) -> Bool {
        lhs.zones == rhs.zones && lhs.percentages == rhs.percentages
    }
}

extension ZoneDistribution: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(zones)
        hasher.combine(percentages)
    }
}

struct CyclingWorkout: Identifiable, Codable {
    let id: UUID
    let startedAtInterval: TimeInterval
    let endedAtInterval: TimeInterval
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
    let zoneDistribution: ZoneDistribution
    let samples: [MetricsSample]

    var startedAt: Date { Date(timeIntervalSince1970: startedAtInterval) }
    var endedAt: Date { Date(timeIntervalSince1970: endedAtInterval) }

    var durationFormatted: String {
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        let h = m / 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m % 60, s) : String(format: "%02d:%02d", m, s)
    }

    init(
        id: UUID,
        startedAt: Date,
        endedAt: Date,
        durationSeconds: Int,
        distanceKm: Double,
        avgPower: Double,
        maxPower: Double,
        normalizedPower: Double,
        avgCadence: Double,
        avgSpeedKmh: Double,
        avgHeartRate: Double,
        calories: Double,
        elevationGainM: Double,
        zoneDistribution: [Int: Double],
        samples: [MetricsSample]
    ) {
        self.id = id
        self.startedAtInterval = startedAt.timeIntervalSince1970
        self.endedAtInterval = endedAt.timeIntervalSince1970
        self.durationSeconds = durationSeconds
        self.distanceKm = distanceKm
        self.avgPower = avgPower
        self.maxPower = maxPower
        self.normalizedPower = normalizedPower
        self.avgCadence = avgCadence
        self.avgSpeedKmh = avgSpeedKmh
        self.avgHeartRate = avgHeartRate
        self.calories = calories
        self.elevationGainM = elevationGainM
        self.zoneDistribution = ZoneDistribution(zoneDistribution)
        self.samples = samples
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case startedAtInterval, endedAtInterval, startedAt, endedAt
        case durationSeconds, distanceKm, avgPower, maxPower, normalizedPower
        case avgCadence, avgSpeedKmh, avgHeartRate, calories, elevationGainM
        case zoneDistribution, samples
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        distanceKm = try container.decode(Double.self, forKey: .distanceKm)
        avgPower = try container.decode(Double.self, forKey: .avgPower)
        maxPower = try container.decode(Double.self, forKey: .maxPower)
        normalizedPower = try container.decode(Double.self, forKey: .normalizedPower)
        avgCadence = try container.decode(Double.self, forKey: .avgCadence)
        avgSpeedKmh = try container.decode(Double.self, forKey: .avgSpeedKmh)
        avgHeartRate = try container.decode(Double.self, forKey: .avgHeartRate)
        calories = try container.decode(Double.self, forKey: .calories)
        elevationGainM = try container.decode(Double.self, forKey: .elevationGainM)
        samples = try container.decode([MetricsSample].self, forKey: .samples)

        if let start = try container.decodeIfPresent(TimeInterval.self, forKey: .startedAtInterval) {
            startedAtInterval = start
        } else {
            startedAtInterval = try container.decode(Date.self, forKey: .startedAt).timeIntervalSince1970
        }
        if let end = try container.decodeIfPresent(TimeInterval.self, forKey: .endedAtInterval) {
            endedAtInterval = end
        } else {
            endedAtInterval = try container.decode(Date.self, forKey: .endedAt).timeIntervalSince1970
        }

        if let zones = try container.decodeIfPresent(ZoneDistribution.self, forKey: .zoneDistribution) {
            zoneDistribution = zones
        } else if let legacy = try container.decodeIfPresent([String: Double].self, forKey: .zoneDistribution) {
            var mapped: [Int: Double] = [:]
            legacy.forEach { key, value in
                if let zone = Int(key) { mapped[zone] = value }
            }
            zoneDistribution = ZoneDistribution(mapped)
        } else {
            zoneDistribution = ZoneDistribution([:])
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startedAtInterval, forKey: .startedAtInterval)
        try container.encode(endedAtInterval, forKey: .endedAtInterval)
        try container.encode(durationSeconds, forKey: .durationSeconds)
        try container.encode(distanceKm, forKey: .distanceKm)
        try container.encode(avgPower, forKey: .avgPower)
        try container.encode(maxPower, forKey: .maxPower)
        try container.encode(normalizedPower, forKey: .normalizedPower)
        try container.encode(avgCadence, forKey: .avgCadence)
        try container.encode(avgSpeedKmh, forKey: .avgSpeedKmh)
        try container.encode(avgHeartRate, forKey: .avgHeartRate)
        try container.encode(calories, forKey: .calories)
        try container.encode(elevationGainM, forKey: .elevationGainM)
        try container.encode(zoneDistribution, forKey: .zoneDistribution)
        try container.encode(samples, forKey: .samples)
    }
}

extension CyclingWorkout: Equatable {
    static func == (lhs: CyclingWorkout, rhs: CyclingWorkout) -> Bool {
        lhs.id == rhs.id
            && lhs.startedAtInterval == rhs.startedAtInterval
            && lhs.endedAtInterval == rhs.endedAtInterval
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
}

extension CyclingWorkout: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(startedAtInterval)
        hasher.combine(endedAtInterval)
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
        hasher.combine(zoneDistribution)
        hasher.combine(samples)
    }
}