//
//  LocalUserManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

class LocalUserManager: ObservableObject {
    @AppStorage("userProfile") private var userProfileData: String?

    var profile: LocalUser {
        get {
            guard let data = userProfileData?.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode(LocalUser.self, from: data)
            else {
                return LocalUser.default
            }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let jsonString = String(data: data, encoding: .utf8) {
                userProfileData = jsonString
            }
        }
    }
}
