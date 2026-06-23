import Foundation

struct SpeedCadenceProfile {
    func parse(_ data: Data, into metrics: inout LiveMetrics) {
        guard data.count >= 7 else { return }
        let flags = data[0]
        if flags & 0x02 != 0 {
            let revolutions = UInt16(data[1]) | (UInt16(data[2]) << 8)
            let time = UInt16(data[3]) | (UInt16(data[4]) << 8)
            if time > 0 {
                let speedRpm = Double(revolutions) / (Double(time) / 1024) * 60
                metrics.speedKmh = speedRpm * 2.1
            }
        }
        if flags & 0x01 != 0, data.count >= 7 {
            metrics.cadence = Double(UInt16(data[5]) | (UInt16(data[6]) << 8)) / 2
        }
    }
}