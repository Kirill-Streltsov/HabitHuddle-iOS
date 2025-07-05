//
//  AppState.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = TokenManager.token != nil
    
    func logout(userManager: LocalUserManager) {
        isAuthenticated = false
        userManager.profile = LocalUser(id: UUID(), username: "", name: "", isSignedInToServer: false)
        TokenManager.token = nil
    }
}
