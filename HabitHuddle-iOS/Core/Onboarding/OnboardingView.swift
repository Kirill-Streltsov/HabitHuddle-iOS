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
    @State private var enteredName: String = ""
    @Namespace private var animation
    
    var pages: [OnboardingPageData] {
        [
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
                symbol: "flame.fill",
                title: "Track streaks & progress",
                text: "Keep an eye on your daily check-ins, current streak, and completion rate.",
                customView: AnyView(
                    HabitStatsCard(habit: Habit.demoHabitWithRecentCheckIns())
                        .offset(y: 24)
                )
            ),
            OnboardingPageData(
                symbol: "person.2.fill",
                title: "Challenge your friends",
                text: "Stay accountable by sending and accepting habit challenges.\nProgress together.",
                customView: AnyView(
                    VStack {
                        ChallengeProgressCardView(
                            challenge: ChallengeDTO(
                                id: UUID(),
                                initiatorName: "Alice",
                                receiverName: "You",
                                habitName: "Read 20 pages a day",
                                type: .competitive,
                                status: .accepted,
                                startDate: Date(),
                                endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                            ),
                            initiatorProgress: 0.62,
                            receiverProgress: 0.83
                        )
                        ChallengeCardView(
                            challenge: ChallengeDTO(
                                id: UUID(),
                                initiatorName: "Jennifer",
                                receiverName: "You",
                                habitName: "Morning runs together",
                                type: .supportive,
                                status: .pending,
                                startDate: Date(),
                                endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                            ),
                            onAccept: {},
                            onReject: {}
                        )
                    }
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
                            HeatmapView(habits: [Habit.demoHabitWithFullCheckIns()])
                        }
                    }
                        .offset(y: 30)
                )
            ),
            OnboardingPageData(
                symbol: "person.fill.questionmark",
                title: "Before we start...",
                text: "What should we call you?",
                customView: AnyView(
                    VStack(spacing: 20) {
                        TextField("Enter your name", text: $enteredName)
                            .textFieldStyle(.plain)
                            .font(.largeTitle)
                            .padding()
                            .padding(.horizontal)
                        
                        Text("We'll use this name throughout the app.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                        .padding(.top, 32)
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
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                
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
                            } else if !enteredName.isEmpty {
                                userManager.profile = LocalUser(
                                    id: UUID(),
                                    username: enteredName.lowercased(),
                                    name: enteredName,
                                    isSignedInToServer: false
                                )
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
                    .disabled(pageIndex == pages.count - 1 && enteredName.isEmpty)
                }
                .padding()
            }
        }
}

#Preview {
    OnboardingView()
}
