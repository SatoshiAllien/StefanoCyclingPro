import SwiftUI

@main
struct StefanoCyclingProWatchApp: App {
    @StateObject private var connectivity = WatchPhoneConnectivity()
    @StateObject private var hrSession = WatchHRSession()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(connectivity)
                .environmentObject(hrSession)
                .onAppear { connectivity.hrSession = hrSession }
        }
    }
}