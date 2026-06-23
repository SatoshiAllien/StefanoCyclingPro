import SwiftUI
import Charts

struct TrainingLoadChartView: View {
    let workouts: [CyclingWorkout]

    private var weeklyLoad: [LoadBar] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: workouts) { w in
            calendar.dateInterval(of: .weekOfYear, for: w.startedAt)?.start ?? w.startedAt
        }
        return grouped
            .map { start, items in
                let load = items.reduce(0.0) { $0 + Double($1.durationSeconds) / 60 * $1.normalizedPower / 100 }
                return LoadBar(weekStart: start, load: load)
            }
            .sorted { $0.weekStart < $1.weekStart }
            .suffix(8)
            .map { $0 }
    }

    var body: some View {
        chartCard("Training Load") {
            if weeklyLoad.isEmpty {
                Text("Complete workouts to track load")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 140)
            } else {
                Chart(weeklyLoad) { bar in
                    BarMark(
                        x: .value("Week", bar.weekStart, unit: .weekOfYear),
                        y: .value("Load", bar.load)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.neonBlue, Theme.neonPurple],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                }
                .chartYAxisLabel("TSS est.")
                .frame(height: 160)
                .animation(.spring(response: 0.5), value: weeklyLoad.count)
            }
        }
    }
}

private struct LoadBar: Identifiable {
    let weekStart: Date
    let load: Double
    var id: Date { weekStart }
}