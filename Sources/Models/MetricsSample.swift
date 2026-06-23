import Foundation

struct MetricsSample: Identifiable, Codable {
    let id: UUID
    let timestampInterval: TimeInterval
    let power: Double
    let cadence: Double
    let speedKmh: Double
    let heartRate: Double

    var timestamp: Date { Date(timeIntervalSince1970: timestampInterval) }

    init(
        id: UUID = UUID(),
        timestamp: Date,
        power: Double,
        cadence: Double,
        speedKmh: Double,
        heartRate: Double
    ) {
        self.id = id
        self.timestampInterval = timestamp.timestampInterval
        self.power = power
        self.cadence = cadence
        self.speedKmh = speedKmh
        self.heartRate = heartRate
    }

    private enum CodingKeys: String, CodingKey {
        case id, timestampInterval, timestamp, power, cadence, speedKmh, heartRate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        power = try container.decode(Double.self, forKey: .power)
        cadence = try container.decode(Double.self, forKey: .cadence)
        speedKmh = try container.decode(Double.self, forKey: .speedKmh)
        heartRate = try container.decode(Double.self, forKey: .heartRate)
        if let interval = try container.decodeIfPresent(TimeInterval.self, forKey: .timestampInterval) {
            timestampInterval = interval
        } else {
            let date = try container.decode(Date.self, forKey: .timestamp)
            timestampInterval = date.timestampInterval
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestampInterval, forKey: .timestampInterval)
        try container.encode(power, forKey: .power)
        try container.encode(cadence, forKey: .cadence)
        try container.encode(speedKmh, forKey: .speedKmh)
        try container.encode(heartRate, forKey: .heartRate)
    }
}

extension MetricsSample: Equatable {
    static func == (lhs: MetricsSample, rhs: MetricsSample) -> Bool {
        lhs.id == rhs.id
            && lhs.timestampInterval == rhs.timestampInterval
            && lhs.power == rhs.power
            && lhs.cadence == rhs.cadence
            && lhs.speedKmh == rhs.speedKmh
            && lhs.heartRate == rhs.heartRate
    }
}

extension MetricsSample: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(timestampInterval)
        hasher.combine(power)
        hasher.combine(cadence)
        hasher.combine(speedKmh)
        hasher.combine(heartRate)
    }
}

private extension Date {
    var timestampInterval: TimeInterval { timeIntervalSince1970 }
}