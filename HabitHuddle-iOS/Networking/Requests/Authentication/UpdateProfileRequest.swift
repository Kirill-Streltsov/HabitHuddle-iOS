//
//  UpdateProfileRequest.swift
//  HabitHuddle-iOS
//

import Foundation

struct UpdateProfileRequest: Encodable {
    let name: String?
    let username: String?
    let email: String?
    let newPassword: String?
    let currentPassword: String?
}
