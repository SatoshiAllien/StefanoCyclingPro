import Foundation

final class MetricsCalculator {
    func estimateCalories(power: Double, duration: TimeInterval) -> Double {
        guard power > 0, duration > 0 else { return 0 }
        return (power * duration / 4184) * 0.239
    }

    func normalizedPower(from samples: [MetricsSample]) -> Double {
        guard !samples.isEmpty else { return 0 }
        let powers = samples.map(\.power)
        let window = 30
        var rolling: [Double] = []
        for i in 0..<powers.count {
            let start = max(0, i - window)
            let slice = powers[start...i]
            let avg = slice.reduce(0, +) / Double(slice.count)
            rolling.append(pow(avg, 4))
        }
        let np = pow(rolling.reduce(0, +) / Double(rolling.count), 0.25)
        return np
    }

    func zoneDistribution(samples: [MetricsSample]) -> [Int: Double] {
        guard !samples.isEmpty else { return [:] }
        var counts = [Int: Int]()
        for s in samples where s.heartRate > 0 {
            let z = PowerZone.zone(for: s.heartRate).rawValue
            counts[z, default: 0] += 1
        }
        let total = Double(counts.values.reduce(0, +))
        guard total > 0 else { return [:] }
        return counts.mapValues { Double($0) / total * 100 }
    }
}