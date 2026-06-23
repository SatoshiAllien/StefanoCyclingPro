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

