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
    private var anchoredQuery: HKAnchoredObjectQuery?
    private var sessionStart: Date?
    private var hrSamples: [Double] = []
    private var lastSentHR = Date.distantPast
    private let sendThrottle: TimeInterval = 1.0

    func start() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        requestHealthAuthorization { [weak self] authorized in
            guard authorized else { return }
            Task { @MainActor in self?.beginWorkoutSession() }
        }
    }

    func stop() {
        let end = Date()
        let duration = Int(end.timeIntervalSince(sessionStart ?? end))
        let avgHR = hrSamples.isEmpty ? heartRate : hrSamples.reduce(0, +) / Double(hrSamples.count)

        stopAnchoredQuery()
        workoutSession?.end()
        builder?.endCollection(withEnd: end) { [weak self] _, _ in
            Task { @MainActor in
                await self?.finishWorkoutCollection()
            }
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

    private func finishWorkoutCollection() async {
        guard let builder else { return }
        if #available(watchOS 10.0, *) {
            _ = try? await builder.finishWorkout()
        } else {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                builder.finishWorkout { _, _ in continuation.resume() }
            }
        }
    }

    private func requestHealthAuthorization(completion: @escaping (Bool) -> Void) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(false)
            return
        }
        let types: Set<HKSampleType> = [hrType, HKObjectType.workoutType()]
        healthStore.requestAuthorization(toShare: types, read: types) { success, _ in
            completion(success)
        }
    }

    private func beginWorkoutSession() {
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
            startAnchoredHRQuery()
            isActive = true
        } catch {}
    }

    private func startAnchoredHRQuery() {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        let query = HKAnchoredObjectQuery(
            type: hrType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            Task { @MainActor in
                self?.processHRSamples(samples)
            }
        }
        query.updateHandler = { [weak self] _, samples, _, _, _ in
            Task { @MainActor in
                self?.processHRSamples(samples)
            }
        }
        healthStore.execute(query)
        anchoredQuery = query
    }

    private func stopAnchoredQuery() {
        if let anchoredQuery {
            healthStore.stop(anchoredQuery)
            self.anchoredQuery = nil
        }
    }

    private func processHRSamples(_ samples: [HKSample]?) {
        guard let sample = samples?.last as? HKQuantitySample else { return }
        let hr = sample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
        applyHeartRate(hr)
    }

    private func applyHeartRate(_ hr: Double) {
        guard hr > 0 else { return }
        heartRate = hr
        hrSamples.append(hr)
        sendHR(hr)
    }

    private func sendHR(_ hr: Double) {
        let now = Date()
        guard now.timeIntervalSince(lastSentHR) >= sendThrottle else { return }
        lastSentHR = now
        transmit(["heartRate": hr])
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
            self.applyHeartRate(hr)
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
#endif