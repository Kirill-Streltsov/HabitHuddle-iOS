//
//  ResetPasswordRequest.swift
//  HabitHuddle-iOS
//

import Foundation

struct ResetPasswordRequest: Encodable {
    let token: String
    let newPassword: String
}
