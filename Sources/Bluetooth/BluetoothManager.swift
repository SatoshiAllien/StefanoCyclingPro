import Foundation
import CoreBluetooth
import Combine

@MainActor
final class BluetoothManager: NSObject, ObservableObject {
    @Published var liveMetrics = LiveMetrics()
    @Published var discoveredSensors: [SensorDevice] = []
    @Published var isScanning = false
    @Published var bluetoothReady = false

    private static let serviceUUIDs = [
        CBUUID(string: "1818"), CBUUID(string: "180D"),
        CBUUID(string: "1816"), CBUUID(string: "1826"),
        CBUUID(string: "180F")
    ]
    private static let batteryServiceUUID = CBUUID(string: "180F")
    private static let batteryLevelUUID = CBUUID(string: "2A19")
    private static let connectionTimeout: TimeInterval = 30
    private static let maxReconnectAttempts = 5
    private static let publishInterval: TimeInterval = 0.25

    private var central: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    private var pendingMetrics = LiveMetrics()
    private var lastPublish = Date.distantPast
    private var reconnectAttempts: [UUID: Int] = [:]
    private var connectionTimers: [UUID: Timer] = [:]
    private var savedSensorIDs: [String] = []

    private let powerProfile = CyclingPowerProfile()
    private let hrProfile = HeartRateProfile()
    private let scProfile = SpeedCadenceProfile()
    private let kickrProfile = WahooKICKRProfile()
    private let speedplayProfile = WahooSpeedplayProfile()

    override init() {
        super.init()
        central = CBCentralManager(delegate: nil, queue: .main)
        central.delegate = self
        savedSensorIDs = UserDefaults.standard.stringArray(forKey: "saved_ble_sensors") ?? []
    }

    func startScanning() {
        guard central.state == .poweredOn else { return }
        isScanning = true
        central.scanForPeripherals(
            withServices: Self.serviceUUIDs,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }

    func stopScanning() {
        isScanning = false
        central.stopScan()
    }

    func connect(_ sensor: SensorDevice) {
        guard let uuid = UUID(uuidString: sensor.id),
              let peripheral = peripherals[uuid] else { return }
        rememberSensor(sensor.id)
        central.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
        startConnectionTimeout(for: peripheral)
    }

    func autoReconnectSaved() {
        for id in savedSensorIDs {
            guard let uuid = UUID(uuidString: id),
                  let peripheral = peripherals[uuid],
                  peripheral.state != .connected else { continue }
            central.connect(peripheral, options: nil)
        }
    }

    private func rememberSensor(_ id: String) {
        if !savedSensorIDs.contains(id) {
            savedSensorIDs.append(id)
            UserDefaults.standard.set(savedSensorIDs, forKey: "saved_ble_sensors")
        }
    }

    private func startConnectionTimeout(for peripheral: CBPeripheral) {
        let id = peripheral.identifier
        connectionTimers[id]?.invalidate()
        connectionTimers[id] = Timer.scheduledTimer(withTimeInterval: Self.connectionTimeout, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.handleConnectionTimeout(peripheral) }
        }
    }

    private func handleConnectionTimeout(_ peripheral: CBPeripheral) {
        guard peripheral.state != .connected else { return }
        central.cancelPeripheralConnection(peripheral)
        updateSensor(peripheral, connected: false)
    }

    private func clearConnectionTimeout(for peripheral: CBPeripheral) {
        connectionTimers[peripheral.identifier]?.invalidate()
        connectionTimers[peripheral.identifier] = nil
    }

    private func scheduleReconnect(for peripheral: CBPeripheral) {
        let id = peripheral.identifier
        let attempts = reconnectAttempts[id, default: 0]
        guard attempts < Self.maxReconnectAttempts else { return }
        reconnectAttempts[id] = attempts + 1
        let delay = min(pow(2.0, Double(attempts)), 30.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, peripheral.state != .connected else { return }
            self.central.connect(peripheral, options: nil)
        }
    }

    private func updateSensor(_ peripheral: CBPeripheral, connected: Bool, battery: Int? = nil, rssi: Int? = nil) {
        guard let idx = discoveredSensors.firstIndex(where: { $0.id == peripheral.identifier.uuidString }) else { return }
        discoveredSensors[idx].isConnected = connected
        if let battery { discoveredSensors[idx].batteryLevel = battery }
        if let rssi { discoveredSensors[idx].rssi = rssi }
    }

    private func parseCharacteristic(_ characteristic: CBCharacteristic, peripheral: CBPeripheral, data: Data) {
        let name = peripheral.name ?? ""

        if characteristic.uuid == Self.batteryLevelUUID {
            if let level = data.first {
                updateSensor(peripheral, connected: peripheral.state == .connected, battery: Int(level))
            }
            return
        }

        if name.lowercased().contains("speedplay") {
            speedplayProfile.parse(data, into: &pendingMetrics)
        } else if name.lowercased().contains("kickr") || name.lowercased().contains("rollr") || serviceIsFTMS(characteristic) {
            kickrProfile.parse(data, into: &pendingMetrics)
        } else if characteristic.uuid == CBUUID(string: "2A63") {
            powerProfile.parse(data, into: &pendingMetrics)
        } else if characteristic.uuid == CBUUID(string: "2A37") {
            hrProfile.parse(data, into: &pendingMetrics)
        } else if characteristic.uuid == CBUUID(string: "2A5B") || characteristic.uuid == CBUUID(string: "2A5C") {
            scProfile.parse(data, into: &pendingMetrics)
        }
        publishMetricsIfNeeded()
    }

    private func publishMetricsIfNeeded() {
        let now = Date()
        guard now.timeIntervalSince(lastPublish) >= Self.publishInterval else { return }
        lastPublish = now
        liveMetrics = pendingMetrics
    }

    private func serviceIsFTMS(_ characteristic: CBCharacteristic) -> Bool {
        characteristic.uuid == CBUUID(string: "2AD2")
            || characteristic.uuid == CBUUID(string: "2AD9")
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            bluetoothReady = central.state == .poweredOn
            if central.state == .poweredOn { autoReconnectSaved() }
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        Task { @MainActor in
            peripherals[peripheral.identifier] = peripheral
            let services = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]) ?? []
            let type = SensorDevice.SensorType.from(peripheralName: peripheral.name ?? "", services: services)
            let battery = parseBatteryFromAdvertisement(advertisementData)
            let device = SensorDevice(
                id: peripheral.identifier.uuidString,
                name: peripheral.name ?? "Unknown",
                type: type,
                isConnected: peripheral.state == .connected,
                batteryLevel: battery,
                rssi: RSSI.intValue
            )
            if let idx = discoveredSensors.firstIndex(where: { $0.id == device.id }) {
                discoveredSensors[idx].rssi = device.rssi
                if let battery { discoveredSensors[idx].batteryLevel = battery }
            } else {
                discoveredSensors.append(device)
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            clearConnectionTimeout(for: peripheral)
            reconnectAttempts[peripheral.identifier] = 0
            peripheral.delegate = self
            peripheral.discoverServices(nil)
            updateSensor(peripheral, connected: true)
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        Task { @MainActor in
            clearConnectionTimeout(for: peripheral)
            updateSensor(peripheral, connected: false)
            scheduleReconnect(for: peripheral)
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        Task { @MainActor in
            updateSensor(peripheral, connected: false)
            scheduleReconnect(for: peripheral)
        }
    }

    @MainActor
    private func parseBatteryFromAdvertisement(_ advertisementData: [String: Any]) -> Int? {
        guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
              let last = manufacturerData.last else { return nil }
        return Int(last)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach { characteristic in
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: "2A19")
                || characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard let data = characteristic.value else { return }
        Task { @MainActor in
            parseCharacteristic(characteristic, peripheral: peripheral, data: data)
        }
    }
}