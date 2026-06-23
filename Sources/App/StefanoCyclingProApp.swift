import SwiftUI

@main
struct StefanoCyclingProApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent") }
                WorkoutView()
                    .tabItem { Label("Workout", systemImage: "figure.outdoor.cycle") }
                SensorListView()
                    .tabItem { Label("Sensors", systemImage: "antenna.radiowaves.left.and.right") }
                HistoryView()
                    .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
            }
            .environmentObject(appState)
            .preferredColorScheme(.dark)
            .tint(Theme.neonGreen)
        }
    }
}