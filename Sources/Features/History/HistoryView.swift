import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    private var vm: HistoryViewModel { HistoryViewModel(appState: appState) }

    var body: some View {
        NavigationStack {
            Group {
                if vm.workouts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bicycle")
                            .font(.largeTitle)
                        Text("No rides yet")
                        Text("Start a workout to build your history.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List(vm.workouts) { w in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(w.startedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.headline)
                            Text("\(String(format: "%.1f", w.distanceKm)) km · \(w.durationFormatted) · \(String(format: "%.0f", w.avgPower)) W avg")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.background)
            .navigationTitle("History")
        }
    }
}