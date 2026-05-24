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
                title: String(localized: .welcomeToHabitHuddle),
                text: String(localized: .buildHabitsStayOnTrackAndGrowStepByStep),
                customView: AnyView(
                    HabitCard(habit: Habit.demoHabitWithRecentCheckIns())
                        .allowsHitTesting(false)
                        .padding(.horizontal)
                )
            ),
            OnboardingPageData(
                symbol: "flame.fill",
                title: String(localized: .trackYourProgress),
                text: String(localized: .trackYourCheckInsStreaksAndProgress),
                customView: AnyView(
                    VStack {
                        CardView {
                            VStack(alignment: .center) {
                                Text(.yourActivityInTheLast2Months)
                                    .font(.headline)
                                HeatmapHabitView(habit: Habit.demoHabitWithFullCheckIns())
                            }
                        }
                        HabitStatsCard(habit: Habit.demoHabitWithRecentCheckIns())
                    }
                        .scaleEffect(0.9)
                )
            ),
            OnboardingPageData(
                symbol: "person.2.fill",
                title: String(localized: .challengeYourFriends),
                text: String(localized: .challengeFriendsAndGrowTogether),
                customView: AnyView(
                    VStack {
                        ChallengeProgressCardView(
                            challenge: ChallengeDTO(
                                id: UUID(),
                                initiatorHabitID: UUID(),
                                receiverHabitID: UUID(),
                                habitName: "Morning runs together",
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
                title: String(localized: .letsStartSmall),
                text: String(localized: .createSpaceForGrowthBeginWithAFewPopularHabits),
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
                            Text(.back)
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
                                    username: "",
                                    name: "",
                                    isSignedInToServer: false
                                )
                                HapticManager.trigger(.success)
                                hasSeenOnboarding = true
                            }
                        }
                    } label: {
                        (pageIndex == pages.count - 1 ? Text(.start) : Text(.next))
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
