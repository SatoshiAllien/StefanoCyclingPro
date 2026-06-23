import Foundation

struct CyclingPowerProfile {
    func parse(_ data: Data, into metrics: inout LiveMetrics) {
        guard data.count >= 4 else { return }
        let flags = data[0]
        let power = Double(UInt16(data[1]) | (UInt16(data[2]) << 8))
        metrics.power = power
        var offset = 3
        if flags & 0x01 != 0, data.count >= offset + 2 {
            let balance = Double(data[offset])
            metrics.leftRightBalance = balance
            offset += 2
        }
        if flags & 0x10 != 0, data.count >= offset + 2 {
            metrics.cadence = Double(UInt16(data[offset]) | (UInt16(data[offset + 1]) << 8)) / 2
        }
    }
}