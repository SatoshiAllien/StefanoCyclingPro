import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var appState: AppState

    private var vm: WorkoutViewModel { WorkoutViewModel(appState: appState) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if vm.isActive {
                    Text(vm.isPaused ? "PAUSED" : "RIDING")
                        .font(.caption.weight(.black))
                        .foregroundStyle(vm.isPaused ? .orange : Theme.neonGreen)
                    Text(vm.elapsedFormatted)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text(String(format: "%.0f W", appState.liveMetrics.power))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Theme.neonGreen)
                    PrimaryWorkoutButton("Stop Workout", color: .red) { vm.stop() }
                } else {
                    Text("Ready to ride")
                        .font(.title2.bold())
                    PrimaryWorkoutButton("Start Workout", color: Theme.neonGreen) { vm.start() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.background)
            .navigationTitle("Workout")
        }
    }
}

struct PrimaryWorkoutButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 32)
    }
}