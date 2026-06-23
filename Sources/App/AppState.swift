import Foundation
import Combine
import UIKit

@MainActor
final class AppState: ObservableObject {
    @Published var liveMetrics = LiveMetrics()
    @Published var isWorkoutActive = false
    @Published var workouts: [CyclingWorkout] = []
    @Published var sensors: [SensorDevice] = []
    @Published var chartSamples: [MetricsSample] = []
    @Published var watchHRConnected = false
    @Published var healthAuthorized = false

    let bluetooth = BluetoothManager()
    let healthKit = HealthKitService()
    let watchConnectivity = WatchConnectivityManager()
    let recorder = WorkoutRecorder()
    let storage = StorageService()
    let calculator = MetricsCalculator()

    private var merger = MetricsMerger()
    private var cancellables = Set<AnyCancellable>()
    private var chartTimer: Timer?
    private var healthKitTimer: Timer?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    init() {
        workouts = storage.loadWorkouts()
        bindServices()
    }

    private func bindServices() {
        bluetooth.$liveMetrics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] metrics in
                self?.mergeBLEMetrics(metrics)
            }
            .store(in: &cancellables)

        watchConnectivity.$heartRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hr in
                guard let self else { return }
                if hr > 0 { self.merger.watchHeartRate = hr }
                self.merger.watchSessionActive = self.watchConnectivity.sessionActive
                self.applyHeartRate()
            }
            .store(in: &cancellables)

        watchConnectivity.$sessionActive
            .receive(on: DispatchQueue.main)
            .sink { [weak self] active in
                guard let self else { return }
                self.merger.watchSessionActive = active
                self.watchHRConnected = active && self.merger.watchHeartRate > 0
                self.applyHeartRate()
            }
            .store(in: &cancellables)

        watchConnectivity.$isReachable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reachable in
                guard let self else { return }
                if !reachable, !self.watchConnectivity.sessionActive {
                    self.watchHRConnected = false
                }
            }
            .store(in: &cancellables)
    }

    func requestPermissions() async {
        healthAuthorized = await healthKit.requestAuthorization()
        if healthAuthorized {
            if let vo2 = await healthKit.fetchLatestVO2Max() {
                liveMetrics.vo2Max = vo2
            }
            if let hr = await healthKit.fetchLatestHeartRate() {
                merger.healthKitHeartRate = hr
                applyHeartRate()
            }
        }
    }

    func startWorkout() {
        isWorkoutActive = true
        chartSamples = []
        merger.reset()
        recorder.start()
        beginBackgroundTask()
        watchConnectivity.startHRSession()
        bluetooth.startScanning()
        bluetooth.autoReconnectSaved()

        chartTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickChart() }
        }
        healthKitTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in await self?.pollHealthKitHeartRate() }
        }
    }

    func stopWorkout() {
        chartTimer?.invalidate()
        chartTimer = nil
        healthKitTimer?.invalidate()
        healthKitTimer = nil
        isWorkoutActive = false
        watchConnectivity.stopHRSession()
        endBackgroundTask()

        let workout = recorder.finish(
            metrics: liveMetrics,
            samples: chartSamples,
            calculator: calculator
        )
        workouts.insert(workout, at: 0)
        storage.saveWorkouts(workouts)
        Task { await healthKit.saveWorkout(workout) }
        merger.reset()
        watchHRConnected = false
    }

    private func mergeBLEMetrics(_ ble: LiveMetrics) {
        merger.mergeBLE(ble, into: &liveMetrics)
        liveMetrics.calories = calculator.estimateCalories(power: liveMetrics.power, duration: recorder.elapsed)
        liveMetrics.distanceKm = recorder.distanceKm(speedKmh: liveMetrics.speedKmh)
        liveMetrics.elevationM = recorder.elevationM
    }

    private func applyHeartRate() {
        merger.resolvedHeartRate(into: &liveMetrics)
        watchHRConnected = merger.watchSessionActive && merger.watchHeartRate > 0
    }

    private func pollHealthKitHeartRate() async {
        guard isWorkoutActive else { return }
        guard merger.watchHeartRate <= 0, merger.bleHeartRate <= 0 else { return }
        if let hr = await healthKit.fetchLatestHeartRate(), hr > 0 {
            merger.healthKitHeartRate = hr
            applyHeartRate()
        }
    }

    private func tickChart() {
        recorder.tick(speedKmh: liveMetrics.speedKmh)
        liveMetrics.calories = calculator.estimateCalories(power: liveMetrics.power, duration: recorder.elapsed)
        liveMetrics.distanceKm = recorder.distanceKm(speedKmh: liveMetrics.speedKmh)
        liveMetrics.elevationM = recorder.elevationM

        if recorder.shouldAutoPause(speedKmh: liveMetrics.speedKmh) {
            liveMetrics.isPaused = true
        } else if isWorkoutActive {
            liveMetrics.isPaused = false
        }

        chartSamples.append(MetricsSample(
            timestamp: Date(),
            power: liveMetrics.power,
            cadence: liveMetrics.cadence,
            speedKmh: liveMetrics.speedKmh,
            heartRate: liveMetrics.heartRate
        ))
        if chartSamples.count > 3600 { chartSamples.removeFirst(chartSamples.count - 3600) }
    }

    private func beginBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        guard backgroundTaskID != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
}