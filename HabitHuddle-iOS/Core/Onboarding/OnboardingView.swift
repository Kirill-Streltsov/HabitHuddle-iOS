//
//  OnboardingView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @State private var pageIndex = 0
    @Namespace private var animation

    let pages: [OnboardingPageData] = [
        OnboardingPageData(
            symbol: "hand.wave.fill",
            title: "Welcome to\nHabit Huddle",
            text: "Create powerful habits, stay on track,\nand become your best self — one step at a time.",
            customView: AnyView(
                HabitCard(habit: Habit.demoHabitWithRecentCheckIns())
                    .disabled(true)
            )
        ),
        OnboardingPageData(
            symbol: "person.2.fill",
            title: "Challenge your friends",
            text: "Stay accountable by sending and accepting habit challenges.\nProgress together.",
            customView: AnyView(
                VStack {
                    ChallengeCardView(
                        challenge: ChallengeDTO(
                            id: UUID(),
                            initiatorName: "Alice",
                            receiverName: "You",
                            habitName: "No caffeine before sleep",
                            type: .supportive,
                            status: .pending,
                            startDate: Date(),
                            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                        ),
                        onAccept: {},
                        onReject: {}
                    )
                    ChallengeCardView(
                        challenge: ChallengeDTO(
                            id: UUID(),
                            initiatorName: "James",
                            receiverName: "You",
                            habitName: "Read 20 pages a day",
                            type: .competitive,
                            status: .pending,
                            startDate: Date(),
                            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
                        ),
                        onAccept: {},
                        onReject: {}
                    )
                }
            )
        ),
        OnboardingPageData(
            symbol: "flame.fill",
            title: "Track streaks & progress",
            text: "Keep an eye on your daily check-ins, current streak, and completion rate.",
            customView: AnyView(
                HabitStatsCard(habit: Habit.demoHabitWithRecentCheckIns())
                    .offset(y: 24)
            )
        ),
        OnboardingPageData(
            symbol: "figure.martial.arts",
            title: "Ready to grow?",
            text: "Let’s build habits that stick — and have fun doing it.",
            customView: AnyView(
                CardView {
                    VStack(alignment: .center) {
                        Text("Your activity in the last 2 months")
                            .font(.headline)
                        HeatmapView(habit: Habit.demoHabitWithFullCheckIns())
                    }
                }
                .offset(y: 30)
            )
        ),
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                OnboardingContent(page: pages[pageIndex], namespace: animation)

                Spacer()

                HStack(spacing: 16) {
                    if pageIndex > 0 {
                        Button("Back") {
                            withAnimation {
                                pageIndex -= 1
                            }
                        }
                        .buttonStyle(OnboardingButtonStyle(style: .secondary))
                    }

                    if pageIndex < pages.count - 1 {
                        Button("Next") {
                            withAnimation {
                                pageIndex += 1
                            }
                        }
                        .buttonStyle(OnboardingButtonStyle(style: .primary))
                    } else {
                        Button("Start!") {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                HapticManager.trigger(.success)
                                hasSeenOnboarding = true
                            }
                        }
                        .buttonStyle(OnboardingButtonStyle(style: .primary))
                        .matchedGeometryEffect(id: "startButton", in: animation)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .frame(height: 50)
            }
            .animation(.easeInOut(duration: 0.4), value: pageIndex)
        }
    }
}

#Preview {
    OnboardingView()
}
