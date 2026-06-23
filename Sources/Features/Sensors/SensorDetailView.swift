import SwiftUI

struct SensorDetailView: View {
    @EnvironmentObject var appState: AppState
    let sensor: SensorDevice

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(sensor.name).font(.largeTitle.bold())
            Label(sensor.type.rawValue, systemImage: "antenna.radiowaves.left.and.right")
            if let battery = sensor.batteryLevel {
                Label("Battery \(battery)%", systemImage: "battery.100")
            }
            Label("RSSI \(sensor.rssi) dBm", systemImage: "wifi")
            Spacer()
            Button(sensor.isConnected ? "Connected" : "Connect") {
                appState.bluetooth.connect(sensor)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.neonGreen)
            .disabled(sensor.isConnected)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.background)
        .navigationTitle("Sensor")
    }
}