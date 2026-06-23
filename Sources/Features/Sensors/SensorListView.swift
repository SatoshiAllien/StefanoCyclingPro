import SwiftUI

struct SensorListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("Bluetooth") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(appState.bluetooth.bluetoothReady ? "Ready" : "Off")
                            .foregroundStyle(appState.bluetooth.bluetoothReady ? Theme.neonGreen : .orange)
                    }
                    Button(appState.bluetooth.isScanning ? "Scanning…" : "Scan Sensors") {
                        appState.bluetooth.startScanning()
                    }
                    .disabled(!appState.bluetooth.bluetoothReady)
                }
                Section("Discovered") {
                    if appState.bluetooth.discoveredSensors.isEmpty {
                        Text("No sensors found. Enable pedals/trainer and scan.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(appState.bluetooth.discoveredSensors) { sensor in
                        NavigationLink(value: sensor) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(sensor.name).font(.headline)
                                    Text(sensor.type.rawValue).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if sensor.isConnected {
                                    Text("Connected").font(.caption).foregroundStyle(Theme.neonGreen)
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Sensors")
            .navigationDestination(for: SensorDevice.self) { sensor in
                SensorDetailView(sensor: sensor)
            }
        }
    }
}