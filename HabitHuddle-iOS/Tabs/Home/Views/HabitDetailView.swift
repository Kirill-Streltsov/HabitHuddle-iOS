//
//  HabitDetailView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 25.05.25.
//

import SwiftData
import SwiftUI
import UserNotifications

struct HabitDetailView: View {
    
    var habit: Habit
    let aiTextID = 0
    
    @State private var typewriterTextID = UUID()
    @State private var isCheckedIn = false
    @State private var deleteButtonPressed = false
    @State private var showEditSheet = false
    @State private var askOpenAITapped = false
    @State private var scrollTarget: Int? = nil
    
    @StateObject private var viewModel: ViewModel
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: LocalUserManager
    
    init(habit: Habit) {
        _viewModel = StateObject(wrappedValue: ViewModel())
        self.habit = habit
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        
                        habitDescription
                        
                        CheckInCardView(habit: habit) {
                            checkIntoHabit(habit)
                        }
                        
                        SubmitButton(title: "Ask AI about benefits", color: .orange, iconName: "sparkles") {
                            HapticManager.trigger(.impact(.medium))
                            Task {
                                askOpenAITapped = true
                                typewriterTextID = UUID()
                                await viewModel.askAI(about: habit)
                            }
                        }
                        .padding(.horizontal)
                        
                        HabitStatisticsView(habit: habit)
                        
                        if !viewModel.openAIAnswer.isEmpty {
                            CardView {
                                TypewriterText(text: viewModel.openAIAnswer, typingInterval: askOpenAITapped ? 0.02 : 0)
                                    .id(typewriterTextID)
                            }
                            .id(aiTextID)
                        }
                        
                        SubmitButton(title: "Delete Habit", color: .red, iconName: "trash") {
                            HapticManager.trigger(.error)
                            deleteButtonPressed = true
                            Task {
                                await deleteHabit()
                            }
                            dismiss()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                }
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showEditSheet) {
                HabitEditView(viewModel: viewModel)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text(viewModel.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                        if let icon = viewModel.icon {
                            Image(systemName: icon)
                                .font(.title3)
                        }
                    }
                }
            }
            .toolbar {
                Button {
                    showEditSheet = true
                } label: {
                    HStack {
                        Text("Edit")
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .onAppear {
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("⏰ Pending notifications:")
                    for request in requests {
                        print("• \(request.identifier) — \(request.content.body)")
                    }
                }
                populateFields(with: habit)
                isCheckedIn = habit.isCheckedInToday
                viewModel.habit = habit
            }
            .onChange(of: viewModel.duration) { _, newValue in
                Task {
                    await MainActor.run {
                        habit.duration = newValue
                        try? context.save()
                    }
                }
            }
            .onChange(of: viewModel.openAIAnswer) { _, answer in
                if askOpenAITapped {
                    scrollTarget = aiTextID
                    if !answer.isEmpty {
                        habit.aiText = answer
                        try? context.save()
                    }
                }
            }
            .onChange(of: scrollTarget) { _, target in
                if let target = target {
                    withAnimation {
                        proxy.scrollTo(target, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var habitDescription: some View {
        Text(habit.habitDescription)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .padding(.bottom)
            .padding(.horizontal)
    }
    
    private func populateFields(with habit: Habit) {
        viewModel.name = habit.name
        viewModel.description = habit.habitDescription
        viewModel.icon = habit.icon
        viewModel.duration = habit.duration
        if let aiText = habit.aiText {
            viewModel.openAIAnswer = aiText
        }
        if let reminderTime = habit.reminderTime {
            viewModel.reminderTime = reminderTime
            viewModel.hasReminder = true
        } else {
            viewModel.hasReminder = false
        }
    }
    
    private func checkIntoHabit(_ habit: Habit) {
        Task {
            if userManager.profile.isSignedInToServer {
                let result = await viewModel.checkIntoHabit(with: habit.id)
                Helpers.handleResult(result) { checkedIn in
                    print("✅ The user has checked in: \(checkedIn)")
                } onFailure: { error in
                    print("❌ Error: Posting the check in: \(error)")
                }
            }
        }
    }
    
    private func deleteHabit() async {
        context.delete(habit)
        try? context.save()
        
        Task {
            if userManager.profile.isSignedInToServer {
                let result = await viewModel.deleteHabit(with: habit.id)
                Helpers.handleResult(result) { codableHabit in
                    print("✅ Deleted the habit on the server with habit name: '\(codableHabit.name)' and id: '\(codableHabit.id)'")
                } onFailure: { error in
                    print("❌ Error: Failed to delete the habit on the server: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    HabitDetailView(habit: Habit.demoHabitWith13Of14CheckIns())
}
