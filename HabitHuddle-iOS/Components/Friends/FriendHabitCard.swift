//
//  FriendHabitCard.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//


import SwiftUI
import SwiftData

struct FriendHabitCard: View {

    @State private var scale: Double = 1
    @State private var didSendBoost: Bool
    @State private var showDurationPicker = false
    @State private var challengeDays: Int = 14
    @State private var durationPickerValid: Bool = true

    @Environment(\.modelContext) private var context

    let habitDTO: HabitDTO
    let isChallengePending: Bool
    var onSendBoost: @MainActor () async -> Void
    var onChallenge: @MainActor (Int) async -> Void

    init(
        habitDTO: HabitDTO,
        isBoosted: Bool,
        isChallengePending: Bool,
        onSendBoost: @escaping @MainActor () async -> Void,
        onChallenge: @escaping @MainActor (Int) async -> Void
    ) {
        self.habitDTO = habitDTO
        self.isChallengePending = isChallengePending
        self._didSendBoost = State(initialValue: isBoosted)
        self.onSendBoost = onSendBoost
        self.onChallenge = onChallenge
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection

            ZStack {
                VStack {
                    if habitDTO.isCheckedInToday {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 85))
                    } else {
                        CheckedInStateView(
                            isOn: didSendBoost,
                            fontSize: 80,
                            shouldFlicker: true,
                            iconOn: "bolt.circle.fill",
                            iconOff: "bolt.circle",
                            color: .orange
                        )
                        .scaleEffect(scale)
                        .allowsHitTesting(!didSendBoost)
                        .onTapGesture {
                            HapticManager.trigger(.success)
                            didSendBoost = true
                            Task { await onSendBoost() }
                            scale += 0.15
                            Task { scale -= 0.15 }
                        }
                        .animation(.easeInOut(duration: 0.3), value: scale)
                    }

                    Text(.tapToBoost)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .opacity(didSendBoost || habitDTO.isCheckedInToday ? 0 : 1)
                }
                .offset(y: -5)
                HStack {
                    StatItem(title: .longestStreak, value: .days(habitDTO.longestStreak))
                    Spacer()
                    StatItem(title: .done, value: "\(habitDTO.completionPercentage)%")
                }
            }
            .offset(y: 15)
            .frame(maxWidth: .infinity)

            HStack(alignment: .bottom) {
                if habitDTO.isCompleted {
                    Text(.habitFinished)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                } else {
                    if let checkIns = habitDTO.checkIns {
                        (Text(verbatim: "\(checkIns.count) / ") + Text(.days(habitDTO.duration.numberOfDays)))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if isChallengePending {
                    Image(systemName: "flag.pattern.checkered.2.crossed")
                        .foregroundStyle(Color.accentColor)
                } else {
                    Button {
                        showDurationPicker = true
                    } label: {
                        Image(systemName: "flag.pattern.checkered.2.crossed")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .padding(.bottom, 4)

            HabitDTOProgressView(habit: habitDTO, height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.label).opacity(0.1), radius: 5, x: 0, y: 4)
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showDurationPicker) {
            challengeSheet
        }
    }

    @ViewBuilder
    private var challengeSheet: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(.challengeDuration)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(habitDTO.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ChallengeDurationPickerView(days: $challengeDays, isValid: $durationPickerValid)

            Text(.pickADurationForTheChallenge)
                .font(.footnote)
                .foregroundStyle(.secondary)

            SubmitButton(
                title: .sendChallenge,
                color: durationPickerValid ? .accentColor : .gray,
                iconName: "flag.pattern.checkered.2.crossed"
            ) {
                showDurationPicker = false
                Task { await onChallenge(challengeDays) }
            }
            .disabled(!durationPickerValid)
        }
        .padding()
        .presentationDetents([.fraction(0.42)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        HStack(alignment: .top) {
            if let icon = habitDTO.icon {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(4)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 8) {
                    Text(habitDTO.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    Spacer()
                }
                if !habitDTO.description.isEmpty {
                    Text(habitDTO.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FriendHabitCard(
        habitDTO: HabitDTO(
            id: UUID(),
            user: LightweightUser(id: UUID()),
            name: "Drink water",
            description: "Drink 2 liters a day",
            category: "",
            duration: .oneWeek,
            reminderTime: .now,
            createdAt: .now,
            updatedAt: .now,
            checkIns: [],
            challenges: nil,
            icon: "brain"),
        isBoosted: false,
        isChallengePending: false,
        onSendBoost: {},
        onChallenge: { _ in }
    )
}
