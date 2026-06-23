import Foundation
import CoreBluetooth
import Combine

@MainActor
final class BluetoothManager: NSObject, ObservableObject {
    @Published var liveMetrics = LiveMetrics()
    @Published var discoveredSensors: [SensorDevice] = []
    @Published var isScanning = false
    @Published var bluetoothReady = false

    private var central: CBCentralManager!
    private var peripherals: [UUID: CBPeripheral] = [:]
    private let powerProfile = CyclingPowerProfile()
    private let hrProfile = HeartRateProfile()
    private let scProfile = SpeedCadenceProfile()
    private let kickrProfile = WahooKICKRProfile()
    private let speedplayProfile = WahooSpeedplayProfile()

    override init() {
        super.init()
        central = CBCentralManager(delegate: nil, queue: .main)
        central.delegate = self
    }

    func startScanning() {
        guard central.state == .poweredOn else { return }
        isScanning = true
        central.scanForPeripherals(
            withServices: [
                CBUUID(string: "1818"), CBUUID(string: "180D"),
                CBUUID(string: "1816"), CBUUID(string: "1826")
            ],
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
        central.connect(peripheral)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            bluetoothReady = central.state == .poweredOn
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
            let battery = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
            let device = SensorDevice(
                id: peripheral.identifier.uuidString,
                name: peripheral.name ?? "Unknown",
                type: type,
                isConnected: peripheral.state == .connected,
                batteryLevel: battery != nil ? Int(battery!.last ?? 0) : nil,
                rssi: RSSI.intValue
            )
            if !discoveredSensors.contains(where: { $0.id == device.id }) {
                discoveredSensors.append(device)
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            peripheral.delegate = self
            peripheral.discoverServices(nil)
            if let idx = discoveredSensors.firstIndex(where: { $0.id == peripheral.identifier.uuidString }) {
                discoveredSensors[idx].isConnected = true
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Task { @MainActor in
            if let idx = discoveredSensors.firstIndex(where: { $0.id == peripheral.identifier.uuidString }) {
                discoveredSensors[idx].isConnected = false
            }
            central.connect(peripheral)
        }
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach { char in
            if char.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        Task { @MainActor in
            let name = peripheral.name ?? ""
            if name.lowercased().contains("speedplay") {
                speedplayProfile.parse(data, into: &liveMetrics)
            } else if name.lowercased().contains("kickr") || serviceIsFTMS(characteristic) {
                kickrProfile.parse(data, into: &liveMetrics)
            } else if characteristic.uuid == CBUUID(string: "2A63") {
                powerProfile.parse(data, into: &liveMetrics)
            } else if characteristic.uuid == CBUUID(string: "2A37") {
                hrProfile.parse(data, into: &liveMetrics)
            } else if characteristic.uuid == CBUUID(string: "2A5B") {
                scProfile.parse(data, into: &liveMetrics)
            }
        }
    }

    private func serviceIsFTMS(_ characteristic: CBCharacteristic) -> Bool {
        characteristic.uuid == CBUUID(string: "2AD2")
    }
}