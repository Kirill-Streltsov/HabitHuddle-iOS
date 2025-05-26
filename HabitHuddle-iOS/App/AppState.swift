//
//  AppState.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftData
import SwiftUI

final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = TokenManager.token != nil
    // @Published var isAuthenticated: Bool = false
}
