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
            symbol: "figure.run",
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
            ForEach(Array(pages.enumerated()), id: \.1.id) { index, page in
                if index == pageIndex {
                    VStack {
                        OnboardingContent(page: page)
                            .frame(height: 650)

                        Spacer()

                        HStack(spacing: 12) {
                            // Back Button with animated appearance
                            if pageIndex != 0 {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        pageIndex -= 1
                                    }
                                } label: {
                                    Text("Back")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.systemGray5))
                                        .foregroundStyle(.primary)
                                        .cornerRadius(12)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }

                            Button {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    if pageIndex < pages.count - 1 {
                                        pageIndex += 1
                                    } else {
                                        hasSeenOnboarding = true
                                    }
                                }
                            } label: {
                                Text(pageIndex == pages.count - 1 ? "Start" : "Next")
                                    .font(.headline)
                                    .foregroundStyle(Color(.systemBackground))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemBlue))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut(duration: 0.3), value: pageIndex)

                        Spacer()
                    }
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: pageIndex)

        }
}

#Preview {
    OnboardingView()
}
