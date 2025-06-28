//
//  OnboardingView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @EnvironmentObject private var userManager: LocalUserManager
    @State private var pageIndex = 0
    @Namespace private var animation
    
    let userID = UUID()
    
    var pages: [OnboardingPageData] {
        [
            OnboardingPageData(
                symbol: "hand.wave.fill",
                title: "Welcome to\nHabit Huddle",
                text: "Build habits, stay on track, and grow step by step.",
                customView: AnyView(
                    HabitCard(habit: Habit.demoHabitWithRecentCheckIns())
                        .allowsHitTesting(false)
                )
            ),
            OnboardingPageData(
                symbol: "flame.fill",
                title: "Track your pogress",
                text: "Track your check-ins, streaks, and progress.",
                customView: AnyView(
                    VStack {
                        CardView {
                            VStack(alignment: .center) {
                                Text("Your activity in the last 2 months")
                                    .font(.headline)
                                HeatmapView(habits: [Habit.demoHabitWithFullCheckIns()])
                            }
                        }
                        HabitStatsCard(habit: Habit.demoHabitWithRecentCheckIns())
                    }
                        .scaleEffect(0.9)
                )
            ),
            OnboardingPageData(
                symbol: "person.2.fill",
                title: "Challenge your friends",
                text: "Challenge friends and grow together.",
                customView: AnyView(
                    VStack {
                        ChallengeProgressCardView(
                            challenge: ChallengeDTO(
                                id: UUID(),
                                initiatorHabitID: UUID(),
                                receiverHabitID: UUID(),
                                habitName: "Morning runs together",
                                type: .supportive,
                                startDate: .now,
                                endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
                                status: .accepted,
                                initiator: .init(
                                    user: .init(
                                        id: UUID(),
                                        username: "jen_the_motivated",
                                        name: "Jennifer",
                                        createdAt: .now,
                                        updatedAt: .now),
                                    progress: 0.81,
                                    checkInCount: 0,
                                    plannedDays: 0),
                                receiver: .init(
                                    user: .init(
                                        id: UUID(),
                                        username: "StreakSeekerMike",
                                        name: "Person",
                                        createdAt: .now,
                                        updatedAt: .now),
                                    progress: 0.81,
                                    checkInCount: 0,
                                    plannedDays: 0))
                        )
                        ChallengeCardView(
                            challenge: ChallengeDTO(
                                id: UUID(),
                                initiatorHabitID: UUID(),
                                receiverHabitID: UUID(),
                                habitName: "No caffeine after noon",
                                type: .competitive,
                                startDate: .now,
                                endDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
                                status: .accepted,
                                initiator: .init(
                                    user: .init(
                                        id: UUID(),
                                        username: "andrew",
                                        name: "Andrew",
                                        createdAt: .now,
                                        updatedAt: .now),
                                    progress: 0.34,
                                    checkInCount: 0,
                                    plannedDays: 0),
                                receiver: .init(
                                    user: .init(
                                        id: UUID(),
                                        username: "george",
                                        name: "You",
                                        createdAt: .now,
                                        updatedAt: .now),
                                    progress: 0.57,
                                    checkInCount: 0,
                                    plannedDays: 0)),
                            onAccept: {},
                            onReject: {}
                        )
                    }
                )
            ),
            OnboardingPageData(
                symbol: "sparkles",
                title: "Let’s Start Small",
                text: "Create space for growth.\nBegin with a few popular habits.",
                customView: AnyView(
                    OnboardingHabitList(userID: userID)
                        .offset(y: -20)
                )
            )
        ]
    }
    
    var body: some View {
            VStack {
                TabView(selection: $pageIndex) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingContent(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .onAppear {
                    UIPageControl.appearance().isHidden = true
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if pageIndex > 0 {
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
                        withAnimation {
                            if pageIndex < pages.count - 1 {
                                pageIndex += 1
                                HapticManager.trigger(.impact(.light))
                            } else {
                                userManager.profile = LocalUser(
                                    id: userID,
                                    username: "username",
                                    name: "user",
                                    isSignedInToServer: false
                                )
                                HapticManager.trigger(.success)
                                hasSeenOnboarding = true
                            }
                        }
                    } label: {
                        Text(pageIndex == pages.count - 1 ? "Start" : "Next")
                            .font(.headline)
                            .foregroundStyle(Color(.systemBackground))
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color(.systemBlue))
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
}

#Preview {
    OnboardingView()
}
