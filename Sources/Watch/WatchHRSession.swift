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
            workoutSession?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { _, _ in }
            isActive = true
        } catch {}
    }

    func stop() {
        workoutSession?.end()
        builder?.endCollection(withEnd: Date()) { _, _ in }
        builder?.finishWorkout { _, _ in }
        isActive = false
    }

    private func sendHR(_ hr: Double) {
        let payload: [String: Any] = ["heartRate": hr]
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil)
        } else {
            try? WCSession.default.updateApplicationContext(payload)
        }
    }
}

extension WatchHRSession: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ session: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
    nonisolated func workoutSession(_ session: HKWorkoutSession, didFailWithError error: Error) {}
}

extension WatchHRSession: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        guard collectedTypes.contains(hrType) else { return }
        let stats = workoutBuilder.statistics(for: hrType)
        let hr = stats?.mostRecentQuantity()?.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0
        Task { @MainActor in
            self.heartRate = hr
            self.sendHR(hr)
        }
    }
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
#endif