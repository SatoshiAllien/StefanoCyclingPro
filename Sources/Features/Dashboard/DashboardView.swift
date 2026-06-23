import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var page = 0

    private var vm: DashboardViewModel { DashboardViewModel(appState: appState) }

    var body: some View {
        NavigationStack {
            TabView(selection: $page) {
                page1.tag(0)
                page2.tag(1)
                chartsPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .background(Theme.background)
            .navigationTitle("StefanoCyclingPro")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AppLogoView(size: 32)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HRSourceIndicator(
                        source: vm.metrics.heartRateSource,
                        isWatchReachable: appState.watchConnectivity.isReachable
                    )
                }
            }
            .task { await appState.requestPermissions() }
        }
    }

    private var page1: some View {
        VStack(spacing: 20) {
            Text(String(format: "%.0f", vm.metrics.power))
                .font(.system(size: 96, weight: .black, design: .rounded))
                .foregroundStyle(Theme.neonGreen)
                .shadow(color: Theme.neonGreen.opacity(0.4), radius: 20)
            Text("WATTS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            HStack(spacing: 16) {
                GaugeView(title: "Cadence", value: vm.metrics.cadence, max: 120, unit: "rpm", color: Theme.neonBlue)
                GaugeView(title: "Speed", value: vm.metrics.speedKmh, max: 60, unit: "km/h", color: Theme.neonPurple)
                GaugeView(title: "HR", value: vm.metrics.heartRate, max: 200, unit: "bpm", color: vm.metrics.currentZone.color)
            }
            ZoneIndicator(zone: vm.metrics.currentZone, heartRate: vm.metrics.heartRate)
                .padding(.horizontal)
            Text("HR Source: \(vm.heartRateSourceLabel)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var page2: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(title: "Balance L/R", value: String(format: "%.0f/%.0f", vm.metrics.leftRightBalance, 100 - vm.metrics.leftRightBalance), unit: "%", accent: Theme.neonBlue)
            MetricCard(title: "Torque Eff.", value: String(format: "%.0f", vm.metrics.torqueEffectiveness), unit: "%", accent: Theme.neonGreen)
            MetricCard(title: "Smoothness", value: String(format: "%.0f", vm.metrics.pedalSmoothness), unit: "%", accent: Theme.neonPurple)
            MetricCard(title: "Calories", value: String(format: "%.0f", vm.metrics.calories), unit: "kcal", accent: .orange)
            MetricCard(title: "Distance", value: String(format: "%.2f", vm.metrics.distanceKm), unit: "km", accent: Theme.neonBlue)
            MetricCard(title: "Elevation", value: String(format: "%.0f", vm.metrics.elevationM), unit: "m", accent: Theme.neonGreen)
        }
        .padding()
    }

    private var chartsPage: some View {
        ScrollView {
            VStack(spacing: 16) {
                PowerChartView(samples: vm.samples)
                CadenceChartView(samples: vm.samples)
                SpeedChartView(samples: vm.samples)
                HeartRateChartView(samples: vm.samples)
                ZoneDistributionChartView(distribution: vm.zoneDistribution)
                TrainingLoadChartView(workouts: appState.workouts)
            }
            .padding()
        }
    }
}