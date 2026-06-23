import Foundation

/// Heart-rate and live-metrics merger (aka HeartRateMerger).
/// Resolves live metric fields using sensor priority rules.
struct MetricsMerger {
    private(set) var watchHeartRate: Double = 0
    private(set) var bleHeartRate: Double = 0
    private(set) var healthKitHeartRate: Double = 0
    private(set) var watchSessionActive = false

    mutating func reset() {
        watchHeartRate = 0
        bleHeartRate = 0
        healthKitHeartRate = 0
        watchSessionActive = false
    }

    mutating func updateWatchHeartRate(_ hr: Double) {
        watchHeartRate = hr
    }

    mutating func updateHealthKitHeartRate(_ hr: Double) {
        healthKitHeartRate = hr
    }

    mutating func updateWatchSessionActive(_ active: Bool) {
        watchSessionActive = active
    }

    /// Priority: Apple Watch → BLE strap → HealthKit background HR.
    func resolvedHeartRate(into metrics: inout LiveMetrics) {
        if watchSessionActive, watchHeartRate > 0 {
            metrics.heartRate = watchHeartRate
            metrics.heartRateSource = .appleWatch
        } else if bleHeartRate > 0 {
            metrics.heartRate = bleHeartRate
            metrics.heartRateSource = .ble
        } else if healthKitHeartRate > 0 {
            metrics.heartRate = healthKitHeartRate
            metrics.heartRateSource = .healthKit
        } else {
            metrics.heartRateSource = .unknown
        }
        metrics.currentZone = PowerZone.zone(for: metrics.heartRate)
    }

    mutating func mergeBLE(_ ble: LiveMetrics, into metrics: inout LiveMetrics) {
        if ble.power > 0 { metrics.power = ble.power }
        if ble.cadence > 0 { metrics.cadence = ble.cadence }
        if ble.speedKmh > 0 { metrics.speedKmh = ble.speedKmh }
        if ble.leftRightBalance > 0 { metrics.leftRightBalance = ble.leftRightBalance }
        if ble.torqueEffectiveness > 0 { metrics.torqueEffectiveness = ble.torqueEffectiveness }
        if ble.pedalSmoothness > 0 { metrics.pedalSmoothness = ble.pedalSmoothness }
        if ble.heartRate > 0 { bleHeartRate = ble.heartRate }
        resolvedHeartRate(into: &metrics)
    }
}