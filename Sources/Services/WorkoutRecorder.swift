import Foundation
import CoreMotion

final class WorkoutRecorder {
    private(set) var startedAt: Date?
    private(set) var elapsed: TimeInterval = 0
    private var timer: Timer?
    private var lastSpeedKmh: Double = 0
    private var distanceM: Double = 0
    private let altimeter = CMAltimeter()
    private(set) var elevationM: Double = 0
    private var baseAltitude: Double?

    var elapsedSeconds: Int { Int(elapsed) }

    func start() {
        startedAt = Date()
        elapsed = 0
        distanceM = 0
        elevationM = 0
        baseAltitude = nil
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsed += 1
        }
        startAltimeter()
    }

    func tick(speedKmh: Double) {
        lastSpeedKmh = speedKmh
        distanceM += (speedKmh / 3.6)
    }

    func distanceKm(speedKmh: Double) -> Double {
        if distanceM == 0 && elapsed > 0 {
            distanceM = (speedKmh / 3.6) * elapsed
        }
        return distanceM / 1000
    }

    func shouldAutoPause(speedKmh: Double) -> Bool {
        speedKmh < 2 && elapsed > 30
    }

    func finish(metrics: LiveMetrics, samples: [MetricsSample], calculator: MetricsCalculator) -> CyclingWorkout {
        timer?.invalidate()
        timer = nil
        stopAltimeter()
        let end = Date()
        let start = startedAt ?? end
        let powers = samples.map(\.power)
        let cadences = samples.map(\.cadence)
        let speeds = samples.map(\.speedKmh)
        let hrs = samples.filter { $0.heartRate > 0 }.map(\.heartRate)

        return CyclingWorkout(
            id: UUID(),
            startedAt: start,
            endedAt: end,
            durationSeconds: Int(end.timeIntervalSince(start)),
            distanceKm: metrics.distanceKm,
            avgPower: powers.isEmpty ? 0 : powers.reduce(0, +) / Double(powers.count),
            maxPower: powers.max() ?? 0,
            normalizedPower: calculator.normalizedPower(from: samples),
            avgCadence: cadences.isEmpty ? 0 : cadences.reduce(0, +) / Double(cadences.count),
            avgSpeedKmh: speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count),
            avgHeartRate: hrs.isEmpty ? 0 : hrs.reduce(0, +) / Double(hrs.count),
            calories: metrics.calories,
            elevationGainM: elevationM,
            zoneDistribution: calculator.zoneDistribution(samples: samples),
            samples: samples
        )
    }

    private func startAltimeter() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else { return }
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            let alt = data.relativeAltitude.doubleValue
            if self.baseAltitude == nil { self.baseAltitude = alt }
            self.elevationM = max(0, alt - (self.baseAltitude ?? 0))
        }
    }

    private func stopAltimeter() {
        altimeter.stopRelativeAltitudeUpdates()
    }
}