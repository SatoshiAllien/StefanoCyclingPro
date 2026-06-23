import SwiftUI

#if os(watchOS)
@main
struct StefanoCyclingProWatchApp: App {
    @StateObject private var connectivity = WatchAppExtension()
    @StateObject private var hrSession = WatchHRSession()

    var body: some Scene {
        WindowGroup {
            WatchHRView()
                .environmentObject(connectivity)
                .environmentObject(hrSession)
                .onAppear { connectivity.hrSession = hrSession }
        }
    }
}
#endif