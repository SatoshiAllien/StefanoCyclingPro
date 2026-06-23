import Foundation

enum HeartRateSource: String, Codable, Hashable {
    case ble, appleWatch, healthKit, unknown

    var displayName: String {
        switch self {
        case .appleWatch: return "Watch"
        case .ble: return "BLE"
        case .healthKit: return "HealthKit"
        case .unknown: return "—"
        }
    }
}

struct LiveMetrics: Codable {
    var power: Double = 0
    var cadence: Double = 0
    var speedKmh: Double = 0
    var heartRate: Double = 0
    var heartRateSource: HeartRateSource = .unknown
    var leftRightBalance: Double = 50
    var torqueEffectiveness: Double = 0
    var pedalSmoothness: Double = 0
    var calories: Double = 0
    var distanceKm: Double = 0
    var elevationM: Double = 0
    var vo2Max: Double?
    var currentZone: PowerZone = .z1
    var isPaused: Bool = false
}

struct MetricsSample: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    let timestamp: Date
    let power: Double
    let cadence: Double
    let speedKmh: Double
    let heartRate: Double

    init(timestamp: Date, power: Double, cadence: Double, speedKmh: Double, heartRate: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.power = power
        self.cadence = cadence
        self.speedKmh = speedKmh
        self.heartRate = heartRate
    }

    static func == (lhs: MetricsSample, rhs: MetricsSample) -> Bool {
        lhs.id == rhs.id
            && lhs.timestamp.timeIntervalSince1970 == rhs.timestamp.timeIntervalSince1970
            && lhs.power == rhs.power
            && lhs.cadence == rhs.cadence
            && lhs.speedKmh == rhs.speedKmh
            && lhs.heartRate == rhs.heartRate
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(timestamp.timeIntervalSince1970)
        hasher.combine(power)
        hasher.combine(cadence)
        hasher.combine(speedKmh)
        hasher.combine(heartRate)
    }
}