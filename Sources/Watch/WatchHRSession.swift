import Foundation
import HealthKit
import WatchConnectivity

#if os(watchOS)
@MainActor
final class WatchHRSession: NSObject, ObservableObject {
    @Published var heartRate: Double = 0
    @Published var isActive = false

    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var sessionStart: Date?
    private var hrSamples: [Double] = []

    func start() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let config = HKWorkoutConfiguration()
        config.activityType = .cycling
        config.locationType = .indoor

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = workoutSession?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            workoutSession?.delegate = self
            builder?.delegate = self
            sessionStart = Date()
            hrSamples = []
            workoutSession?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { _, _ in }
            isActive = true
        } catch {}
    }

    func stop() {
        let end = Date()
        let duration = Int(end.timeIntervalSince(sessionStart ?? end))
        let avgHR = hrSamples.isEmpty ? heartRate : hrSamples.reduce(0, +) / Double(hrSamples.count)

        workoutSession?.end()
        builder?.endCollection(withEnd: end) { [weak self] _, _ in
            self?.builder?.finishWorkout { _, _ in }
        }
        isActive = false

        let summary = WatchWorkoutModel(
            heartRate: heartRate,
            avgHeartRate: avgHR,
            durationSeconds: duration,
            calories: 0,
            timestamp: end
        )
        sendSummary(summary)
        sessionStart = nil
        hrSamples = []
    }

    private func sendHR(_ hr: Double) {
        guard hr > 0 else { return }
        let payload: [String: Any] = ["heartRate": hr]
        transmit(payload)
    }

    private func sendSummary(_ model: WatchWorkoutModel) {
        var payload = model.dictionaryPayload
        payload["workoutSummary"] = model.dictionaryPayload
        transmit(payload)
    }

    private func transmit(_ payload: [String: Any]) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil, errorHandler: nil)
        } else {
            try? session.updateApplicationContext(payload)
        }
    }
}

extension WatchHRSession: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ session: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {}

    nonisolated func workoutSession(_ session: HKWorkoutSession, didFailWithError error: Error) {}
}

extension WatchHRSession: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        guard collectedTypes.contains(hrType) else { return }
        let stats = workoutBuilder.statistics(for: hrType)
        let hr = stats?.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0
        Task { @MainActor in
            self.heartRate = hr
            if hr > 0 { self.hrSamples.append(hr) }
            self.sendHR(hr)
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
#endif