import Foundation

struct WahooKICKRProfile {
    func parse(_ data: Data, into metrics: inout LiveMetrics) {
        guard data.count >= 4 else { return }
        let power = Double(UInt16(data[2]) | (UInt16(data[3]) << 8))
        if power > 0 { metrics.power = power }
        if data.count >= 6 {
            metrics.cadence = Double(UInt16(data[4]) | (UInt16(data[5]) << 8)) / 2
        }
        if data.count >= 8 {
            let speedRaw = Double(UInt16(data[6]) | (UInt16(data[7]) << 8))
            metrics.speedKmh = speedRaw / 100
        }
    }
}