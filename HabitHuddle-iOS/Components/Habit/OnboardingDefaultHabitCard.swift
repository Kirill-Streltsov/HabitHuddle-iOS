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
    
    var body: some View {
        CardView {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .center, spacing: 16) {
                    Text(habit.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    Text(habit.habitDescription)
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                    Picker("Duration", selection: $duration) {
                        ForEach(HabitDuration.allCases) { option in
                            Text("\(option.numberOfDays) days")
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
                    .onTapGesture {
                        withAnimation {
                            isSelected.toggle()
                        }
                    }
                }
            }
        }
        .scaleEffect(isSelected ? 0.9 : 0.8)
    }
}

#Preview {
    OnboardingDefaultHabitCard(habit: Habit.demoHabitWithRecentCheckIns(), isSelected: .constant(false), duration: .constant(.oneWeek))
}
