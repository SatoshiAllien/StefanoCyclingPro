import Foundation
import WatchConnectivity
import Combine

#if os(watchOS)
@MainActor
final class WatchAppExtension: NSObject, ObservableObject {
    @Published var isPhoneReachable = false

    weak var hrSession: WatchHRSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
}

extension WatchAppExtension: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            isPhoneReachable = session.isReachable
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            isPhoneReachable = session.isReachable
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in handleCommand(message) }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        Task { @MainActor in handleCommand(userInfo) }
    }

    @MainActor
    private func handleCommand(_ payload: [String: Any]) {
        guard let command = payload["command"] as? String else { return }
        switch command {
        case "startHR":
            hrSession?.start()
        case "stopHR":
            hrSession?.stop()
        default:
            break
        }
    }
}
#endif