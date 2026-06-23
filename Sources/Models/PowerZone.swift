import SwiftUI

enum PowerZone: Int, CaseIterable, Codable, Identifiable {
    case z1 = 1, z2, z3, z4, z5, z6, z7

    var id: Int { rawValue }

    var label: String { "Z\(rawValue)" }

    var name: String {
        switch self {
        case .z1: return "Recovery"
        case .z2: return "Endurance"
        case .z3: return "Tempo"
        case .z4: return "Threshold"
        case .z5: return "VO2max"
        case .z6: return "Anaerobic"
        case .z7: return "Neuromuscular"
        }
    }

    var color: Color {
        switch self {
        case .z1: return Color(hex: "00B0FF")
        case .z2: return Color(hex: "00E676")
        case .z3: return Color(hex: "FFD600")
        case .z4: return Color(hex: "FF9100")
        case .z5: return Color(hex: "FF3D00")
        case .z6: return Color(hex: "D500F9")
        case .z7: return Color(hex: "AA00FF")
        }
    }

    static func zone(for heartRate: Double, maxHR: Double = 190) -> PowerZone {
        let pct = heartRate / maxHR
        switch pct {
        case ..<0.6: return .z1
        case ..<0.7: return .z2
        case ..<0.8: return .z3
        case ..<0.85: return .z4
        case ..<0.9: return .z5
        case ..<0.95: return .z6
        default: return .z7
        }
    }
}