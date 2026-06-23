import Foundation
import Combine
import HealthKit

@MainActor
final class HealthKitService: ObservableObject {
    private let store = HKHealthStore()

    private let readTypes: Set<HKObjectType> = {
        var types = Set<HKObjectType>()
        let baseIds: [HKQuantityTypeIdentifier] = [
            .heartRate, .distanceCycling, .vo2Max, .activeEnergyBurned
        ]
        baseIds.forEach { id in
            if let t = HKQuantityType.quantityType(forIdentifier: id) { types.insert(t) }
        }
        if #available(iOS 17.0, *) {
            if let cyclingPower = HKQuantityType.quantityType(forIdentifier: .cyclingPower) {
                types.insert(cyclingPower)
            }
        }
        types.insert(HKObjectType.workoutType())
        return types
    }()

    private let writeTypes: Set<HKSampleType> = {
        var types = Set<HKSampleType>()
        types.insert(HKObjectType.workoutType())
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(energy)
        }
        if let dist = HKQuantityType.quantityType(forIdentifier: .distanceCycling) {
            types.insert(dist)
        }
        return types
    }()

    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
            return true
        } catch {
            return false
        }
    }

    func fetchLatestVO2Max() async -> Double? {
        guard let vo2Type = HKQuantityType.quantityType(forIdentifier: .vo2Max) else { return nil }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: vo2Type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?
                    .quantity
                    .doubleValue(for: HKUnit(from: "ml/kg*min"))
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    func saveWorkout(_ workout: CyclingWorkout) async {
        let energy = HKQuantity(unit: .kilocalorie(), doubleValue: workout.calories)
        let distance = HKQuantity(unit: .meter(), doubleValue: workout.distanceKm * 1000)
        let workoutType = HKWorkoutActivityType.cycling

        let hkWorkout = HKWorkout(
            activityType: workoutType,
            start: workout.startedAt,
            end: workout.endedAt,
            duration: Double(workout.durationSeconds),
            totalEnergyBurned: energy,
            totalDistance: distance,
            metadata: ["creator": "StefanoCyclingPro"]
        )

        try? await store.save(hkWorkout)
    }
}