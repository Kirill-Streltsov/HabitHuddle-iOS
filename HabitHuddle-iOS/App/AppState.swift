//
//  AppState.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftUI
import Observation

@Observable
final class AppState: ObservableObject {
    var isAuthenticated: Bool = false
}
