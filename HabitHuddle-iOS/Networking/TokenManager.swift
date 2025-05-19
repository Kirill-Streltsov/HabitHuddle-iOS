//
//  TokenManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import Foundation

final class TokenManager {
    private enum Keys {
        static let token = "authToken"
    }
    
    static var token: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.token)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: Keys.token)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.token)
            }
        }
    }
    
    static func clearToken() {
        UserDefaults.standard.removeObject(forKey: Keys.token)
    }
}
