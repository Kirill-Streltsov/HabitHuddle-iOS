//
//  DeepLinkRouter.swift
//  HabitHuddle-iOS
//

import Foundation

enum DeepLinkRouter {

    /// Parses an incoming Universal Link URL for a password reset token.
    /// Returns the token string if the URL matches the reset path and carries a non-empty token query item.
    static func parseResetPasswordToken(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        guard components.path == "/reset-password" else { return nil }
        guard let token = components.queryItems?.first(where: { $0.name == "token" })?.value, !token.isEmpty else { return nil }
        return token
    }
}

/// Shared deep-link state observed by `RootView` and written to by `SceneDelegate`.
/// Universal links in SwiftUI `WindowGroup` apps are delivered to the scene, not the
/// app delegate, and SwiftUI's `.onContinueUserActivity` modifier does not reliably
/// receive cold-start activities — so `SceneDelegate` owns both paths.
@MainActor
final class DeepLinkState: ObservableObject {

    static let shared = DeepLinkState()

    @Published var resetPasswordToken: String?

    private init() {}

    @discardableResult
    func handle(_ url: URL) -> Bool {
        guard let token = DeepLinkRouter.parseResetPasswordToken(from: url) else { return false }
        // Defer to the next runloop so the assignment is observed by SwiftUI's
        // sheet binding even when the link arrives during cold-start scene
        // connection, before `RootView` has mounted.
        DispatchQueue.main.async { [weak self] in
            self?.resetPasswordToken = token
        }
        return true
    }

    @discardableResult
    func handle(_ activity: NSUserActivity) -> Bool {
        guard activity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = activity.webpageURL else { return false }
        return handle(url)
    }
}
