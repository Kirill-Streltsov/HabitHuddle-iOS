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
    @State private var showCheckIns = false

    @StateObject private var viewModel: ViewModel

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userManager: LocalUserManager

    private var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE, d. MMMM yyyy"
        return df
    }()

    private var timeFormatter: DateFormatter = {
        let tf = DateFormatter()
        tf.dateFormat = "H:mm"
        return tf
    }()

    init(habit: Habit) {
        _viewModel = StateObject(wrappedValue: ViewModel())
        self.habit = habit
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CheckInCardView(habit: habit)

                    if !habit.habitDescription.isEmpty {
                        descriptionSection
                    }

                    HabitStatisticsView(habit: habit)
                        .frame(maxWidth: .infinity)

                    if !habit.checkIns.isEmpty {
                        checkInsSection
                    }

                    aiSection
                        .id(aiTextID)

                    SubmitButton(title: .deleteHabit, color: .red, iconName: "trash") {
                        HapticManager.trigger(.error)
                        deleteButtonPressed = true
                        Task { await deleteHabit() }
                        dismiss()
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
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
                Button { showEditSheet = true } label: { Text(.edit) }
            }
            .onAppear {
                populateFields(with: habit)
                isCheckedIn = habit.isCheckedInToday
                viewModel.habit = habit
            }
            .onChange(of: viewModel.duration) { _, newValue in
                Task {
                    await MainActor.run {
                        habit.duration = newValue
                        context.saveOrLog()
                    }
                }
            }
            .onChange(of: viewModel.openAIAnswer) { _, answer in
                if askOpenAITapped {
                    scrollTarget = aiTextID
                    if !answer.isEmpty {
                        habit.aiText = answer
                        context.saveOrLog()
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

    // MARK: - Sections

    private var descriptionSection: some View {
        detailCard {
            Text(habit.habitDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
        }
    }

    private var checkInsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader(.checkInHistory)
            detailCard {
                VStack(spacing: 0) {
                    Button {
                        withAnimation { showCheckIns.toggle() }
                    } label: {
                        HStack {
                            settingsIcon("checkmark.circle.fill", color: .mint)
                            Text(showCheckIns ? .hideCheckInHistory : .viewCheckInHistory)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: showCheckIns ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(minHeight: 44)
                        .padding(.horizontal, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if showCheckIns {
                        cardDivider
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(habit.checkIns.sorted(by: { $0.date < $1.date }).map({ $0.date }), id: \.self) { date in
                                HStack(alignment: .center) {
                                    Text(dateFormatter.string(from: date))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(timeFormatter.string(from: date))
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                }
                                .padding(.horizontal, 12)
                                .frame(minHeight: 44)
                                Divider().padding(.leading, 12)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
    }

    private var aiSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader(.aiInsights)
            detailCard {
                VStack(spacing: 0) {
                    Button {
                        HapticManager.trigger(.impact(.medium))
                        Task {
                            askOpenAITapped = true
                            typewriterTextID = UUID()
                            await viewModel.askAI(about: habit)
                        }
                    } label: {
                        HStack {
                            settingsIcon("sparkles", color: .orange)
                            Text(viewModel.isLoadingAIResponse ? .thinking : .askAiAboutBenefits)
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.isLoadingAIResponse {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .frame(minHeight: 44)
                        .padding(.horizontal, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if !viewModel.openAIAnswer.isEmpty {
                        cardDivider
                        TypewriterText(
                            text: viewModel.openAIAnswer,
                            typingInterval: askOpenAITapped ? 0.02 : 0
                        )
                        .id(typewriterTextID)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func detailCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func sectionHeader(_ key: LocalizedStringResource) -> some View {
        Text(key)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
    }

    private func settingsIcon(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .medium))
            .frame(width: 28, height: 28)
            .foregroundStyle(.white)
            .background(color.gradient)
            .clipShape(.rect(cornerRadius: 7))
    }

    private var cardDivider: some View {
        Divider().padding(.leading, 52)
    }

    // MARK: - Data

    private func populateFields(with habit: Habit) {
        viewModel.name = habit.name
        viewModel.description = habit.habitDescription
        viewModel.isSynced = habit.isSyncable
        viewModel.isPublic = habit.isPublic
        viewModel.category = habit.category
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

    private func deleteHabit() async {
        habit.cancelHabitNotification()
        context.delete(habit)
        context.saveOrLog()

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

#if DEBUG
#Preview {
    HabitDetailView(habit: Habit.demoHabitWith13Of14CheckIns())
}
#endif
