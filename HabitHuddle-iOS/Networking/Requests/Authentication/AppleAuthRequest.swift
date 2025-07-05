//
//  AppleAuthRequest.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 30.06.25.
//

import Foundation
struct AppleAuthRequest: Codable {
    let identityToken: String
    let name: String
    let deviceToken: String
}
