//
//  AppState.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import Observation
import SwiftUI

final class AppState: ObservableObject {
    var isAuthenticated: Bool = TokenManager.token != nil
}
