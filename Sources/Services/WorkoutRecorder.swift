import Foundation
import CoreMotion

final class WorkoutRecorder {
    private let queue = DispatchQueue(label: "com.stefanociancimino.workout-recorder", qos: .userInitiated)

    private var _startedAt: Date?
    private var _elapsed: TimeInterval = 0
    private var timer: Timer?
    private var distanceM: Double = 0
    private let altimeter = CMAltimeter()
    private var _elevationM: Double = 0
    private var baseAltitude: Double?

    var elapsedSeconds: Int { Int(elapsed) }

    var elapsed: TimeInterval {
        queue.sync { _elapsed }
    }

    var elevationM: Double {
        queue.sync { _elevationM }
    }

    func start() {
        queue.sync {
            _startedAt = Date()
            _elapsed = 0
            distanceM = 0
            _elevationM = 0
            baseAltitude = nil
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.queue.async { self?._elapsed += 1 }
        }
        startAltimeter()
    }

    func tick(speedKmh: Double) {
        queue.async { [weak self] in
            self?.distanceM += speedKmh / 3.6
        }
    }

    func distanceKm(speedKmh: Double) -> Double {
        queue.sync {
            if distanceM == 0, _elapsed > 0 {
                distanceM = (speedKmh / 3.6) * _elapsed
            }
            return distanceM / 1000
        }
    }

    func shouldAutoPause(speedKmh: Double) -> Bool {
        queue.sync { speedKmh < 2 && _elapsed > 30 }
    }

    func finish(metrics: LiveMetrics, samples: [MetricsSample], calculator: MetricsCalculator) -> CyclingWorkout {
        timer?.invalidate()
        timer = nil
        stopAltimeter()

        return queue.sync {
            let end = Date()
            let start = _startedAt ?? end
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
                elevationGainM: _elevationM,
                zoneDistribution: calculator.zoneDistribution(samples: samples),
                samples: samples
            )
        }
    }

    private func startAltimeter() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else { return }
        altimeter.startRelativeAltitudeUpdates(to: queue) { [weak self] data, _ in
            guard let self, let data else { return }
            let alt = data.relativeAltitude.doubleValue
            if self.baseAltitude == nil { self.baseAltitude = alt }
            self._elevationM = max(0, alt - (self.baseAltitude ?? 0))
        }
    }

    private func stopAltimeter() {
        altimeter.stopRelativeAltitudeUpdates()
    }
}