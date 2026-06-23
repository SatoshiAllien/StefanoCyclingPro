import Foundation

/// Charts update once per second via AppState; this caps rendered points for performance.
enum ChartThrottle {
    static let maxVisibleSamples = 120

    static func displaySamples(from samples: [MetricsSample]) -> [MetricsSample] {
        guard samples.count > maxVisibleSamples else { return samples }
        return Array(samples.suffix(maxVisibleSamples))
    }
}