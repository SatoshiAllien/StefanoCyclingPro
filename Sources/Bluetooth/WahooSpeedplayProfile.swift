import Foundation

struct WahooSpeedplayProfile {
    func parse(_ data: Data, into metrics: inout LiveMetrics) {
        CyclingPowerProfile().parse(data, into: &metrics)
        if data.count >= 8 {
            metrics.torqueEffectiveness = Double(data[6])
            metrics.pedalSmoothness = Double(data[7])
        }
    }
}