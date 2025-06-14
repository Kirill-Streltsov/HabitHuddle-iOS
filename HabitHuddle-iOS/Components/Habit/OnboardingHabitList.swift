//
//  OnboardingHabitList.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 08.06.25.
//

import SwiftUI
import SwiftData

struct OnboardingHabitList: View {
    
    @Environment(\.modelContext) private var context
    
    let defaultHabits = Habit.createTestHabitsWithCheckIns()
    let userID: UUID
    @State private var isHabitSelected = [false, false, false]
    @State private var habitDuration: [HabitDuration] = [.twoWeeks, .twoWeeks, .twoWeeks]
    
    var body: some View {
        
        VStack(spacing: 0) {
            ForEach(0..<3) { index in
                OnboardingDefaultHabitCard(habit: defaultHabits[index], isSelected: $isHabitSelected[index], duration: $habitDuration[index])
            }
            Text("Habits selected: \(isHabitSelected.filter { $0 == true }.count) / 3")
                .font(.headline)
                .foregroundStyle(Color.gray)
        }
        .onDisappear {
            Task {
                for index in isHabitSelected.indices {
                    if isHabitSelected[index] {
                        let habit = Habit(
                            id: defaultHabits[index].id,
                            user: LightweightUser(id: userID),
                            name: defaultHabits[index].name,
                            description: defaultHabits[index].habitDescription,
                            duration: habitDuration[index])
                        context.insert(habit)
                    }
                }
                try? context.save()
            }
        }
    }
}

#Preview {
    OnboardingHabitList(userID: UUID())
}
