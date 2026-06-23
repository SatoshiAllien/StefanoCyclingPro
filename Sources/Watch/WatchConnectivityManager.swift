import Foundation
import WatchConnectivity
import Combine

@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    @Published var heartRate: Double = 0
    @Published var isReachable = false
    @Published var sessionActive = false

    private var session: WCSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func startHRSession() {
        sessionActive = true
        send(["command": "startHR"])
    }

    func stopHRSession() {
        sessionActive = false
        send(["command": "stopHR"])
    }

    private func send(_ message: [String: Any]) {
        guard let session else { return }
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        } else {
            session.transferUserInfo(message)
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in isReachable = session.isReachable }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in handlePayload(message) }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        Task { @MainActor in handlePayload(userInfo) }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in handlePayload(applicationContext) }
    }

    @MainActor
    private func handlePayload(_ payload: [String: Any]) {
        if let hr = payload["heartRate"] as? Double {
            heartRate = hr
        }
    }

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif
}