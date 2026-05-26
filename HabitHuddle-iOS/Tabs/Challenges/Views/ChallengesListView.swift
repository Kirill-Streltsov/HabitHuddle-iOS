//
//  ChallengesList.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI
import SwiftData

struct ChallengesListView: View {

    enum Segment: Hashable {
        case active, invites, past
    }

    @StateObject private var viewModel: ViewModel

    @Query
    var challenges: [Challenge]

    @Query
    var habits: [Habit]

    @Query
    var users: [User]

    @State private var showToast = false
    @State private var message = ""
    @State private var selectedChallenge: ChallengeDTO? = nil
    @State private var ongoingChallengeID = UUID()
    @State private var processingChallengeIDs: Set<UUID> = []
    @State private var selectedSegment: Segment = .active
    @State private var didAutoSelectSegment = false

    @Environment(\.modelContext) private var context
    @EnvironmentObject var appState: AppState

    let userID: UUID

    init(userID: UUID) {
        self.userID = userID
        _viewModel = StateObject(wrappedValue: ViewModel(userID: userID))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if appState.isAuthenticated {
                    segmentPicker
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                }
                ScrollView {
                    if !appState.isAuthenticated {
                        UnauthenticatedView(description: .logInToViewAndTakePartInChallengesWithFriends)
                    } else {
                        segmentContent
                    }
                }
                .refreshable {
                    await viewModel.getChallenges(for: userID)
                    ongoingChallengeID = UUID()
                }
            }
            .toast(
                isPresented: $showToast,
                message: message,
                icon: "flag.pattern.checkered.2.crossed"
            )
            .background(Color(.systemGroupedBackground))
            .task {
                await viewModel.getChallenges(for: userID)
                autoSelectSegmentIfNeeded()
            }
            .onChange(of: viewModel.challenges) { _, newChallenges in
                if !newChallenges.isEmpty {
                    for newChallenge in viewModel.acceptedChallenges {
                        if !challenges.contains(where: { $0.id == newChallenge.id }) {
                            updateLocalStorage(from: newChallenge)
                        }
                    }
                }
                autoSelectSegmentIfNeeded()
            }
            .onChange(of: habits) { _, _ in
                for newChallenge in viewModel.acceptedChallenges {
                    if !challenges.contains(where: { $0.id == newChallenge.id }) {
                        updateLocalStorage(from: newChallenge)
                    }
                }
            }
            .sheet(item: $selectedChallenge) { challenge in
                ChallengeCheckInsListView(challenge: challenge)
            }
            .navigationTitle(String(localized: .challenges))
        }
    }

    // MARK: - Segmented control

    private var segmentPicker: some View {
        Picker("", selection: $selectedSegment) {
            Text(String(localized: .active)).tag(Segment.active)
            Text(invitesLabel).tag(Segment.invites)
            Text(String(localized: .past)).tag(Segment.past)
        }
        .pickerStyle(.segmented)
    }

    private var invitesLabel: String {
        let base = String(localized: .invites)
        let count = viewModel.invitesCount
        return count > 0 ? "\(base) (\(count))" : base
    }

    /// On first load, open the Invites segment if the user has anything waiting on them.
    private func autoSelectSegmentIfNeeded() {
        guard !didAutoSelectSegment else { return }
        if viewModel.invitesCount > 0 {
            selectedSegment = .invites
        }
        didAutoSelectSegment = true
    }

    // MARK: - Segment bodies

    @ViewBuilder
    private var segmentContent: some View {
        switch selectedSegment {
        case .active:
            activeSegment
        case .invites:
            invitesSegment
        case .past:
            pastSegment
        }
    }

    @ViewBuilder
    private var activeSegment: some View {
        if viewModel.acceptedChallenges.isEmpty {
            EmptyContentView(
                icon: "flag.slash",
                title: .noActiveChallengesYet,
                description: .startAChallengeWithAFriendToStayAccountableAndReachYourGoalsTogether
            )
        } else {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.acceptedChallenges) { challenge in
                    ChallengeProgressCardView(challenge: challenge)
                        .id(ongoingChallengeID)
                        .onTapGesture {
                            HapticManager.trigger(.selection)
                            selectedChallenge = challenge
                        }
                }
            }
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var invitesSegment: some View {
        let received = viewModel.pendingChallengesReceived
        let sent = viewModel.pendingChallengesSent
        if received.isEmpty && sent.isEmpty {
            EmptyContentView(
                icon: "envelope",
                title: .noInvites,
                description: .challengeInvitesYouSendOrReceiveWillShowUpHere
            )
        } else {
            LazyVStack(alignment: .leading, spacing: 16) {
                if !received.isEmpty {
                    subheader(.received)
                    ForEach(received) { challenge in
                        challengeCard(with: challenge)
                    }
                }
                if !sent.isEmpty {
                    subheader(.sent)
                    ForEach(sent) { challenge in
                        SentChallengeCardView(challenge: challenge) {
                            let result = await viewModel.cancelChallenge(with: challenge.id)
                            Helpers.handleResult(result) { status in
                                if status == .ok {
                                    showToast = true
                                    message = String(localized: .challengeWithdrawn)
                                    HapticManager.trigger(.success)
                                    Task {
                                        await viewModel.getChallenges(for: userID)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var pastSegment: some View {
        let past = viewModel.pastChallenges
        if past.isEmpty {
            EmptyContentView(
                icon: "clock.arrow.circlepath",
                title: .noPastChallenges,
                description: .finishedChallengesAndDeclinedInvitesWillBeArchivedHere
            )
        } else {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(groupedPast(past), id: \.key) { group in
                    Text(verbatim: group.key)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    ForEach(group.value) { challenge in
                        PastChallengeCardView(challenge: challenge)
                            .onTapGesture {
                                guard challenge.status == .completed else { return }
                                HapticManager.trigger(.selection)
                                selectedChallenge = challenge
                            }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func subheader(_ resource: LocalizedStringResource) -> some View {
        Text(resource)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 8)
    }

    /// Groups past challenges by "Month YYYY" using the end date, preserving sort order (newest first).
    private func groupedPast(_ challenges: [ChallengeDTO]) -> [(key: String, value: [ChallengeDTO])] {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        var order: [String] = []
        var groups: [String: [ChallengeDTO]] = [:]
        for challenge in challenges {
            let key = formatter.string(from: challenge.endDate)
            if groups[key] == nil {
                order.append(key)
                groups[key] = []
            }
            groups[key]?.append(challenge)
        }
        return order.map { ($0, groups[$0] ?? []) }
    }

    // MARK: - Local persistence helpers (unchanged behavior)

    private func updateLocalStorage(from challenge: ChallengeDTO) {
        if challenges.contains(where: { $0.id == challenge.id }) { return }
        if processingChallengeIDs.contains(challenge.id) { return }

        if let habit = habits.first(where: { $0.id == challenge.initiatorHabitID || $0.id == challenge.receiverHabitID }) {
            saveChallengeLocally(from: challenge, for: habit)
            return
        }

        let myHabitIDOnServer = challenge.initiator.user.id == userID
            ? challenge.initiatorHabitID
            : challenge.receiverHabitID
        if myHabitIDOnServer != nil { return }

        processingChallengeIDs.insert(challenge.id)
        getHabit(from: challenge)
    }

    private func challengeCard(with challenge: ChallengeDTO) -> some View {
        ChallengeCardView(challenge: challenge) {
            let acceptedResult = await viewModel.acceptChallenge(with: challenge.id)
            Helpers.handleResult(acceptedResult) { status in
                if status == .ok {
                    HapticManager.trigger(.success)
                    message = String(localized: .challengeAccepted)
                    showToast = true
                    Task {
                        await viewModel.getChallenges(for: userID)
                    }
                    updateLocalStorage(from: challenge)
                }
            } onFailure: { error in
                print("❌ Error: Failed to accept the challenge: \(error.localizedDescription)")
            }
        } onReject: {
            let rejectedResult = await viewModel.rejectChallenge(with: challenge.id)
            Helpers.handleResult(rejectedResult) { status in
                if status == .ok {
                    HapticManager.trigger(.success)
                    message = String(localized: .challengeRejected)
                    showToast = true
                }
                Task {
                    await viewModel.getChallenges(for: userID)
                }
                print("✅ Successfully rejected the challenge with id: \(challenge.id)")
            } onFailure: { error in
                print("❌ Error: Failed to reject the challenge: \(error.localizedDescription)")
            }
        }
    }

    private func getHabit(from challenge: ChallengeDTO) {
        let templateHabitID: UUID?
        if challenge.initiator.user.id == userID {
            templateHabitID = challenge.receiverHabitID
        } else {
            templateHabitID = challenge.initiatorHabitID
        }
        guard let habitID = templateHabitID else {
            print("❌ Error: No template habit ID for challenge \(challenge.id)")
            processingChallengeIDs.remove(challenge.id)
            return
        }
        Task {
            let result = await viewModel.getHabitFromChallenge(with: habitID)
            Helpers.handleResult(result) { habitDTO in
                var habitToSend = habitDTO
                habitToSend.id = UUID()
                createHabitAfterAcceptingChallenge(habitDTO: habitToSend, challengeDTO: challenge)
            } onFailure: { error in
                print("❌ Error: Fetching template habit for challenge \(challenge.id): \(error)")
                processingChallengeIDs.remove(challenge.id)
            }
        }
    }

    private func createHabitAfterAcceptingChallenge(habitDTO: HabitDTO, challengeDTO: ChallengeDTO) {
        Task {
            defer { processingChallengeIDs.remove(challengeDTO.id) }
            let sentHabitResult = await viewModel.createHabitAfterAcceptingChallenge(habitDTO: habitDTO, for: challengeDTO.id)
            Helpers.handleResult(sentHabitResult) { createdHabit in
                if !habits.contains(where: { $0.id == createdHabit.id }) {
                    let habit = createdHabit.saved(in: context)
                    habit.isPublic = true
                    do {
                        try context.save()
                        saveChallengeLocally(from: challengeDTO, for: habit)
                        print("✅ Habit created from challenge successfully.")
                    } catch {
                        print("❌ Error: Couldn't save habit locally: \(error)")
                    }
                }
            } onFailure: { error in
                print("❌ Error: Something went wrong creating habit: \(error)")
            }
        }
    }

    private func saveChallengeLocally(from challengeDTO: ChallengeDTO, for habit: Habit) {
        let initiator = users.first(where: { $0.id == challengeDTO.initiator.user.id })
            ?? challengeDTO.initiator.user.toSwiftData()
        let receiver = users.first(where: { $0.id == challengeDTO.receiver.user.id })
            ?? challengeDTO.receiver.user.toSwiftData()
        let challenge = challengeDTO.toSwiftData(initiator: initiator, receiver: receiver, habit: habit)
        do {
            context.insert(challenge)
            try context.save()
        } catch {
            print("❌ Error: Couldn't save challenge locally: \(error)")
        }
    }
}

#Preview {
    ChallengesListView(userID: UUID())
}
