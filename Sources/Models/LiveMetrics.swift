import Foundation

enum HeartRateSource: String, Codable {
    case ble, appleWatch, healthKit, unknown
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

struct MetricsSample: Identifiable, Codable {
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
}