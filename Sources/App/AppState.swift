import Foundation
import Combine

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

    private var cancellables = Set<AnyCancellable>()
    private var chartTimer: Timer?

    init() {
        workouts = storage.loadWorkouts()
        bindServices()
    }

    private func bindServices() {
        bluetooth.$liveMetrics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] metrics in
                self?.mergeMetrics(metrics)
            }
            .store(in: &cancellables)

        watchConnectivity.$heartRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hr in
                guard let self, hr > 0 else { return }
                self.liveMetrics.heartRate = hr
                self.liveMetrics.heartRateSource = .appleWatch
                self.watchHRConnected = true
            }
            .store(in: &cancellables)

        watchConnectivity.$isReachable
            .assign(to: &$watchHRConnected)
    }

    func requestPermissions() async {
        healthAuthorized = await healthKit.requestAuthorization()
        if healthAuthorized, let vo2 = await healthKit.fetchLatestVO2Max() {
            liveMetrics.vo2Max = vo2
        }
    }

    func startWorkout() {
        isWorkoutActive = true
        chartSamples = []
        recorder.start()
        watchConnectivity.startHRSession()
        bluetooth.startScanning()

        chartTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickChart() }
        }
    }

    func stopWorkout() {
        chartTimer?.invalidate()
        chartTimer = nil
        isWorkoutActive = false
        watchConnectivity.stopHRSession()

        let workout = recorder.finish(
            metrics: liveMetrics,
            samples: chartSamples,
            calculator: calculator
        )
        workouts.insert(workout, at: 0)
        storage.saveWorkouts(workouts)
        Task { await healthKit.saveWorkout(workout) }
    }

    private func mergeMetrics(_ ble: LiveMetrics) {
        if ble.power > 0 { liveMetrics.power = ble.power }
        if ble.cadence > 0 { liveMetrics.cadence = ble.cadence }
        if ble.speedKmh > 0 { liveMetrics.speedKmh = ble.speedKmh }
        if ble.leftRightBalance > 0 { liveMetrics.leftRightBalance = ble.leftRightBalance }
        if ble.torqueEffectiveness > 0 { liveMetrics.torqueEffectiveness = ble.torqueEffectiveness }
        if ble.pedalSmoothness > 0 { liveMetrics.pedalSmoothness = ble.pedalSmoothness }
        liveMetrics.calories = calculator.estimateCalories(power: liveMetrics.power, duration: recorder.elapsed)
        liveMetrics.distanceKm = recorder.distanceKm(speedKmh: liveMetrics.speedKmh)
        liveMetrics.elevationM = recorder.elevationM
        liveMetrics.currentZone = PowerZone.zone(for: liveMetrics.heartRate)
    }

    private func tickChart() {
        recorder.tick(speedKmh: liveMetrics.speedKmh)
        liveMetrics.calories = calculator.estimateCalories(power: liveMetrics.power, duration: recorder.elapsed)
        liveMetrics.distanceKm = recorder.distanceKm(speedKmh: liveMetrics.speedKmh)

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
        if chartSamples.count > 3600 { chartSamples.removeFirst() }
    }
}