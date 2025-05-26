//
//  SessionManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.05.25.
//

import SwiftData
import SwiftUI
import Observation

@Observable
class SessionManager {
    
    static let shared = SessionManager()
    
    var isAuthenticated: Bool = TokenManager.token != nil
    
    var currentUser: User? {
        willSet {
            if newValue == nil {
                TokenManager.clearToken()
            }
        }
    }

    func loadCurrentUser(from context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<User>()
            let users = try context.fetch(descriptor)

            self.currentUser = users.first // You might have a better filter for "logged in"
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }

    func logout(from context: ModelContext) {
        currentUser = nil
    }
}
