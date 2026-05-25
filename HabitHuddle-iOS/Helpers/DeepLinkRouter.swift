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
