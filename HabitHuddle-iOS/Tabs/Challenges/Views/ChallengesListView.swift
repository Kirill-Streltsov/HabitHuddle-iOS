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
            .onChange(of: viewModel.invitesCount) { oldValue, newValue in
                if oldValue > 0 && newValue == 0 && selectedSegment == .invites {
                    selectedSegment = .active
                }
            }
            .onChange(of: habits) { _, _ in
                for newChallenge in viewModel.acceptedChallenges {
                    if !challenges.contains(where: { $0.id == newChallenge.id }) {
                        updateLocalStorage(from: newChallenge)
                    }
                }
            }
            .sheet(item: $selectedChallenge) { challenge in
                ChallengeCheckInsListView(
                    challenge: challenge,
                    onCancel: challenge.status == .accepted ? { await cancelActiveChallenge(challenge) } : nil
                )
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

    // MARK: - Cancel active

    @MainActor
    private func cancelActiveChallenge(_ challenge: ChallengeDTO) async {
        let result = await viewModel.cancelChallenge(with: challenge.id)
        switch result {
        case .success(let status) where status == .ok:
            deleteLocalChallenge(challenge.id)
            selectedChallenge = nil
            await viewModel.getChallenges(for: userID)
            HapticManager.trigger(.success)
            message = String(localized: .challengeWithdrawn)
            showToast = true
        default:
            HapticManager.trigger(.error)
            message = String(localized: .somethingWentWrongPleaseTryAgain)
            showToast = true
        }
    }

    @MainActor
    private func deleteLocalChallenge(_ id: UUID) {
        guard let local = (try? context.fetch(FetchDescriptor<Challenge>()))?.first(where: { $0.id == id }) else { return }
        context.delete(local)
        try? context.save()
    }

    // MARK: - Accept / reject

    /// Accepts a challenge end-to-end: confirms with the server, makes sure the habit is
    /// stored locally, and only then surfaces success and lets the challenge move into the
    /// Active segment. The card shows a spinner for the duration via `processingChallengeIDs`.
    @MainActor
    private func accept(_ challenge: ChallengeDTO) async {
        guard !processingChallengeIDs.contains(challenge.id) else { return }
        processingChallengeIDs.insert(challenge.id)
        defer { processingChallengeIDs.remove(challenge.id) }

        // 1. Accept on the server.
        let acceptResult = await viewModel.acceptChallenge(with: challenge.id)
        guard case .success(let status) = acceptResult, status == .ok else {
            HapticManager.trigger(.error)
            message = String(localized: .somethingWentWrongPleaseTryAgain)
            showToast = true
            return
        }

        // 2. Make sure the habit exists locally BEFORE we flip the UI to "active".
        do {
            let habit = try await ensureHabitLocally(for: challenge)
            // 3. Refresh so the accepted challenge (now linked to our habit) comes back, then persist it.
            await viewModel.getChallenges(for: userID)
            let acceptedChallenge = viewModel.challenges.first(where: { $0.id == challenge.id }) ?? challenge
            saveChallengeLocally(from: acceptedChallenge, for: habit)

            // 4. Success is only surfaced once the habit is safely in local storage.
            HapticManager.trigger(.success)
            message = String(localized: .challengeAccepted)
            showToast = true
        } catch {
            // The challenge is accepted on the server; the reconcile path will retry the local
            // save on the next refresh. Surface the failure instead of a false success.
            print("❌ Error: Couldn't load the habit for challenge \(challenge.id): \(error)")
            HapticManager.trigger(.error)
            message = String(localized: .somethingWentWrongPleaseTryAgain)
            showToast = true
        }
    }

    @MainActor
    private func reject(_ challenge: ChallengeDTO) async {
        guard !processingChallengeIDs.contains(challenge.id) else { return }
        processingChallengeIDs.insert(challenge.id)
        defer { processingChallengeIDs.remove(challenge.id) }

        let result = await viewModel.rejectChallenge(with: challenge.id)
        switch result {
        case .success(let status):
            if status == .ok {
                HapticManager.trigger(.success)
                message = String(localized: .challengeRejected)
                showToast = true
            }
            await viewModel.getChallenges(for: userID)
        case .failure(let error):
            print("❌ Error: Failed to reject the challenge: \(error.localizedDescription)")
            HapticManager.trigger(.error)
            message = String(localized: .somethingWentWrongPleaseTryAgain)
            showToast = true
        }
    }

    // MARK: - Local persistence helpers

    /// Background reconciliation used on launch / refresh: makes sure every accepted challenge
    /// has its habit and the challenge itself saved locally. Safe to call repeatedly.
    @MainActor
    private func updateLocalStorage(from challenge: ChallengeDTO) {
        guard !challengeExistsLocally(challenge.id) else { return }
        guard !processingChallengeIDs.contains(challenge.id) else { return }
        processingChallengeIDs.insert(challenge.id)
        Task {
            defer { processingChallengeIDs.remove(challenge.id) }
            do {
                let habit = try await ensureHabitLocally(for: challenge)
                saveChallengeLocally(from: challenge, for: habit)
            } catch {
                print("❌ Error: Couldn't reconcile challenge \(challenge.id) locally: \(error)")
            }
        }
    }

    private func challengeCard(with challenge: ChallengeDTO) -> some View {
        ChallengeCardView(
            challenge: challenge,
            isProcessing: processingChallengeIDs.contains(challenge.id)
        ) {
            await accept(challenge)
        } onReject: {
            await reject(challenge)
        }
    }

    /// Returns the local `Habit` that represents the current user's side of this challenge,
    /// fetching and persisting it from the server when it isn't on this device yet.
    ///
    /// Cases handled:
    /// - We already own the habit locally (e.g. we were challenged on our own habit).
    /// - Our habit exists on the server but not locally (e.g. accepted on another device) -> fetch it.
    /// - We have no habit for this challenge yet -> copy the other participant's habit into our own.
    @MainActor
    private func ensureHabitLocally(for challenge: ChallengeDTO) async throws -> Habit {
        let isInitiator = challenge.initiator.user.id == userID
        let myHabitID = isInitiator ? challenge.initiatorHabitID : challenge.receiverHabitID
        let theirHabitID = isInitiator ? challenge.receiverHabitID : challenge.initiatorHabitID

        // 1. Already saved on this device.
        if let myHabitID, let local = existingHabit(myHabitID) { return local }
        if let theirHabitID, let local = existingHabit(theirHabitID) { return local }

        // 2. Our habit already exists on the server but hasn't synced locally yet -> fetch it as-is.
        if let myHabitID {
            return try persistHabitLocally(try await fetchHabit(myHabitID))
        }

        // 3. We don't have a habit for this challenge yet -> copy the other participant's habit.
        guard let theirHabitID else {
            throw HHError.notFound
        }
        var copy = try await fetchHabit(theirHabitID)
        copy.id = UUID()
        let created = try await createOurHabit(from: copy, for: challenge.id)
        return try persistHabitLocally(created)
    }

    @MainActor
    private func fetchHabit(_ id: UUID) async throws -> HabitDTO {
        switch await viewModel.getHabitFromChallenge(with: id) {
        case .success(let dto): return dto
        case .failure(let error): throw error
        }
    }

    @MainActor
    private func createOurHabit(from dto: HabitDTO, for challengeID: UUID) async throws -> HabitDTO {
        switch await viewModel.createHabitAfterAcceptingChallenge(habitDTO: dto, for: challengeID) {
        case .success(let dto): return dto
        case .failure(let error): throw error
        }
    }

    /// Inserts a habit into local storage, skipping if one with the same id is already persisted.
    @MainActor
    @discardableResult
    private func persistHabitLocally(_ dto: HabitDTO) throws -> Habit {
        if let existing = existingHabit(dto.id) { return existing }
        let habit = dto.saved(in: context)
        habit.isPublic = true
        try context.save()
        return habit
    }

    @MainActor
    private func saveChallengeLocally(from challengeDTO: ChallengeDTO, for habit: Habit) {
        guard !challengeExistsLocally(challengeDTO.id) else { return }
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

    /// Looks the habit up directly in the store (not the `@Query`, which lags behind writes).
    @MainActor
    private func existingHabit(_ id: UUID) -> Habit? {
        (try? context.fetch(FetchDescriptor<Habit>()))?.first { $0.id == id }
    }

    @MainActor
    private func challengeExistsLocally(_ id: UUID) -> Bool {
        ((try? context.fetch(FetchDescriptor<Challenge>()))?.contains { $0.id == id }) == true
    }
}

#Preview {
    ChallengesListView(userID: UUID())
}
