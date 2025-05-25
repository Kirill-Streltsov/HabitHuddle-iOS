//
//  NewHabitViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftUI
import SwiftData

extension NewHabitView {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @State var name: String = ""
        @State var description: String = ""
        @State var frequency: HabitFrequency = .daily
        @State var reminderTime: Date?
        @State var createdAt: Date?
        @State var updatedAt: Date?
        
        
        func createHabit() {
            
        }
    }
}
