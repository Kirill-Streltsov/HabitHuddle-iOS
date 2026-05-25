//
//  String+isValidEmail.swift
//  HabitHuddle-iOS
//

import Foundation

extension String {
    /// Returns `true` when the string looks like a syntactically valid email address.
    ///
    /// The check is intentionally pragmatic, not RFC-perfect:
    ///   • exactly one `@`
    ///   • non-empty local part (no spaces, no `@`)
    ///   • domain with at least one dot and a TLD of 2+ characters
    ///
    /// "qwert", "qwert@", "@foo.com", "foo@bar", "foo@bar.x" → false
    /// "foo@bar.io", "user.name+tag@example.co.uk"           → true
    var isValidEmail: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]{2,}$"#
        return trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
}
