import Foundation
import CoreBluetooth

struct SensorDevice: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var type: SensorType
    var isConnected: Bool
    var batteryLevel: Int?
    var rssi: Int

    enum SensorType: String, Codable, CaseIterable {
        case wahooSpeedplay = "Wahoo Speedplay"
        case wahooKickr = "Wahoo KICKR ROLLR"
        case cyclingPower = "Cycling Power (CPS)"
        case heartRate = "Heart Rate (HRM)"
        case speedCadence = "Speed & Cadence (CSC)"
        case ftms = "Fitness Machine (FTMS)"
        case unknown = "Unknown"

        static func from(peripheralName: String, services: [CBUUID]) -> SensorType {
            let name = peripheralName.lowercased()
            if name.contains("speedplay") { return .wahooSpeedplay }
            if name.contains("kickr") || name.contains("rollr") { return .wahooKickr }
            if services.contains(CBUUID(string: "1818")) { return .cyclingPower }
            if services.contains(CBUUID(string: "180D")) { return .heartRate }
            if services.contains(CBUUID(string: "1816")) { return .speedCadence }
            if services.contains(CBUUID(string: "1826")) { return .ftms }
            return .unknown
        }
    }
}