import Foundation
import Combine
import HealthKit

// MARK: - iOS 17-only HealthKit helpers (isolated to avoid availability warnings on iOS 16)

@available(iOS 17.0, *)
private enum HealthKitIOS17 {
    static func cyclingPowerType() -> HKQuantityType? {
        HKQuantityType.quantityType(forIdentifier: .cyclingPower)
    }
}

@MainActor
final class HealthKitService: ObservableObject {
    @Published private(set) var latestHeartRate: Double = 0

    private let store = HKHealthStore()

    private var readTypes: Set<HKObjectType> {
        Self.makeReadTypes()
    }

    private var writeTypes: Set<HKSampleType> {
        Self.makeWriteTypes()
    }

    private static func makeReadTypes() -> Set<HKObjectType> {
        var types = Set<HKObjectType>()
        let baseIds: [HKQuantityTypeIdentifier] = [
            .heartRate, .distanceCycling, .vo2Max, .activeEnergyBurned
        ]
        for id in baseIds {
            if let type = HKQuantityType.quantityType(forIdentifier: id) {
                types.insert(type)
            }
        }
        if #available(iOS 17.0, *) {
            if let cyclingPower = HealthKitIOS17.cyclingPowerType() {
                types.insert(cyclingPower)
            }
        }
        types.insert(HKObjectType.workoutType())
        return types
    }

    private static func makeWriteTypes() -> Set<HKSampleType> {
        var types = Set<HKSampleType>()
        types.insert(HKObjectType.workoutType())
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(energy)
        }
        if let distance = HKQuantityType.quantityType(forIdentifier: .distanceCycling) {
            types.insert(distance)
        }
        return types
    }

    /// Returns cycling power type on iOS 17+, nil on iOS 16 (safe fallback).
    func cyclingPowerQuantityType() -> HKQuantityType? {
        if #available(iOS 17.0, *) {
            return HealthKitIOS17.cyclingPowerType()
        } else {
            return nil
        }
    }

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
        return await fetchLatestQuantity(type: vo2Type, unit: HKUnit(from: "ml/kg*min"))
    }

    func fetchLatestHeartRate() async -> Double? {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return nil }
        let value = await fetchLatestQuantity(
            type: hrType,
            unit: HKUnit.count().unitDivided(by: .minute())
        )
        if let value { latestHeartRate = value }
        return value
    }

    private func fetchLatestQuantity(type: HKQuantityType, unit: HKUnit) async -> Double? {
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?
                    .quantity
                    .doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    func saveWorkout(_ workout: CyclingWorkout) async {
        if #available(iOS 17.0, *) {
            await saveWorkoutModern(workout)
        } else {
            await saveWorkoutLegacy(workout)
        }
    }

    private func saveWorkoutLegacy(_ workout: CyclingWorkout) async {
        let energy = HKQuantity(unit: .kilocalorie(), doubleValue: workout.calories)
        let distance = HKQuantity(unit: .meter(), doubleValue: workout.distanceKm * 1000)
        let hkWorkout = HKWorkout(
            activityType: .cycling,
            start: workout.startedAt,
            end: workout.endedAt,
            duration: Double(workout.durationSeconds),
            totalEnergyBurned: energy,
            totalDistance: distance,
            metadata: ["creator": "StefanoCyclingPro"]
        )
        try? await store.save(hkWorkout)
    }

    @available(iOS 17.0, *)
    private func saveWorkoutModern(_ workout: CyclingWorkout) async {
        let config = HKWorkoutConfiguration()
        config.activityType = .cycling
        config.locationType = .outdoor

        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
        do {
            try await builder.beginCollection(at: workout.startedAt)
            var samples: [HKSample] = []
            if workout.calories > 0,
               let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                samples.append(HKQuantitySample(
                    type: energyType,
                    quantity: HKQuantity(unit: .kilocalorie(), doubleValue: workout.calories),
                    start: workout.startedAt,
                    end: workout.endedAt
                ))
            }
            if workout.distanceKm > 0,
               let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceCycling) {
                samples.append(HKQuantitySample(
                    type: distanceType,
                    quantity: HKQuantity(unit: .meter(), doubleValue: workout.distanceKm * 1000),
                    start: workout.startedAt,
                    end: workout.endedAt
                ))
            }
            if !samples.isEmpty {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    builder.add(samples) { _, error in
                        if let error { continuation.resume(throwing: error) }
                        else { continuation.resume() }
                    }
                }
            }
            try await builder.endCollection(at: workout.endedAt)
            _ = try await builder.finishWorkout()
        } catch {
            await saveWorkoutLegacy(workout)
        }
    }
}