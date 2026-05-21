//
//  OnboardingDefaultHabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 08.06.25.
//

import SwiftUI

struct OnboardingDefaultHabitCard: View {
    
    let habit: Habit
    @Binding var isSelected: Bool
    @Binding var duration: HabitDuration
    
    @State private var showSelect = false
    
    var body: some View {
        CardView {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .center, spacing: 16) {
                    VStack(spacing: 8) {
                        Text(habit.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        Text(habit.habitDescription)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                    }
                    Picker(String(localized: .duration), selection: $duration) {
                        ForEach(HabitDuration.allCases) { option in
                            Text(.days(option.numberOfDays))
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 35, height: 35)
                            
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.title)
                                .foregroundStyle(.green)
                                .fontWeight(.bold)
                        }
                    }
                    .offset(x: 10, y: -10)
                    .sensoryFeedback(.selection, trigger: showSelect)
                    .onTapGesture {
                        showSelect.toggle()
                        withAnimation {
                            isSelected.toggle()
                        }
                    }
                }
            }
        }
        .scaleEffect(isSelected ? 1 : 0.9)
    }
}

#Preview {
    OnboardingDefaultHabitCard(habit: Habit.demoHabitWithRecentCheckIns(), isSelected: .constant(false), duration: .constant(.oneWeek))
}
