import Foundation

struct HeartRateProfile {
    func parse(_ data: Data, into metrics: inout LiveMetrics) {
        guard data.count >= 2 else { return }
        let flags = data[0]
        if flags & 0x01 == 0 {
            metrics.heartRate = Double(data[1])
        } else if data.count >= 3 {
            metrics.heartRate = Double(UInt16(data[1]) | (UInt16(data[2]) << 8))
        }
        metrics.heartRateSource = .ble
    }
}