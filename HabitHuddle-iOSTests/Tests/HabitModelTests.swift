//
//  HabitModelTests.swift
//  HabitHuddle-iOSTests
//

import Testing
import Foundation
@testable import HabitHuddle_iOS

@Suite("Habit model extensions")
struct HabitModelTests {

    // MARK: - Helpers

    private func makeHabit(duration: HabitDuration = .twoWeeks) -> Habit {
        Habit(
            id: UUID(),
            user: LightweightUser(id: UUID()),
            name: "Test",
            description: "",
            isPublic: false,
            duration: duration
        )
    }

    private func checkIn(daysAgo: Int, habit: Habit) -> HabitCheckIn {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        return HabitCheckIn(date: date, habit: habit, habitID: habit.id)
    }

    // MARK: - currentStreak

    @Test("currentStreak is 0 with no check-ins")
    func currentStreakEmpty() {
        let habit = makeHabit()
        #expect(habit.currentStreak == 0)
    }

    @Test("currentStreak counts today only")
    func currentStreakTodayOnly() {
        let habit = makeHabit()
        habit.checkIns = [checkIn(daysAgo: 0, habit: habit)]
        #expect(habit.currentStreak == 1)
    }

    @Test("currentStreak counts consecutive days ending today")
    func currentStreakConsecutiveEndingToday() {
        let habit = makeHabit()
        habit.checkIns = [
            checkIn(daysAgo: 0, habit: habit),
            checkIn(daysAgo: 1, habit: habit),
            checkIn(daysAgo: 2, habit: habit),
        ]
        #expect(habit.currentStreak == 3)
    }

    @Test("currentStreak counts consecutive days ending yesterday")
    func currentStreakConsecutiveEndingYesterday() {
        let habit = makeHabit()
        habit.checkIns = [
            checkIn(daysAgo: 1, habit: habit),
            checkIn(daysAgo: 2, habit: habit),
            checkIn(daysAgo: 3, habit: habit),
        ]
        #expect(habit.currentStreak == 3)
    }

    @Test("currentStreak is 0 when last check-in was 2+ days ago")
    func currentStreakBrokenByGap() {
        let habit = makeHabit()
        // Most recent check-in was 2 days ago — streak should be dead
        habit.checkIns = [
            checkIn(daysAgo: 2, habit: habit),
            checkIn(daysAgo: 3, habit: habit),
            checkIn(daysAgo: 4, habit: habit),
        ]
        #expect(habit.currentStreak == 0)
    }

    @Test("currentStreak stops at a gap in the middle")
    func currentStreakStopsAtGap() {
        let habit = makeHabit()
        habit.checkIns = [
            checkIn(daysAgo: 0, habit: habit),
            checkIn(daysAgo: 1, habit: habit),
            // gap: day 2 missing
            checkIn(daysAgo: 3, habit: habit),
            checkIn(daysAgo: 4, habit: habit),
        ]
        #expect(habit.currentStreak == 2)
    }

    @Test("currentStreak handles duplicate check-ins on the same day")
    func currentStreakDuplicateSameDay() {
        let habit = makeHabit()
        // Two check-ins today (morning and evening) should count as streak of 1
        let morning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let evening = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        habit.checkIns = [
            HabitCheckIn(date: morning, habit: habit, habitID: habit.id),
            HabitCheckIn(date: evening, habit: habit, habitID: habit.id),
        ]
        #expect(habit.currentStreak == 1)
    }

    // MARK: - longestStreak

    @Test("longestStreak is 0 with no check-ins")
    func longestStreakEmpty() {
        let habit = makeHabit()
        #expect(habit.longestStreak == 0)
    }

    @Test("longestStreak with single check-in")
    func longestStreakSingle() {
        let habit = makeHabit()
        habit.checkIns = [checkIn(daysAgo: 5, habit: habit)]
        #expect(habit.longestStreak == 1)
    }

    @Test("longestStreak finds the longest consecutive run")
    func longestStreakFindsMax() {
        let habit = makeHabit()
        habit.checkIns = [
            checkIn(daysAgo: 10, habit: habit),
            checkIn(daysAgo: 9, habit: habit),
            // gap
            checkIn(daysAgo: 5, habit: habit),
            checkIn(daysAgo: 4, habit: habit),
            checkIn(daysAgo: 3, habit: habit),
            checkIn(daysAgo: 2, habit: habit),
        ]
        #expect(habit.longestStreak == 4)
    }

    @Test("longestStreak with all consecutive days")
    func longestStreakAllConsecutive() {
        let habit = makeHabit(duration: .oneWeek)
        habit.checkIns = (0..<7).map { checkIn(daysAgo: $0, habit: habit) }
        #expect(habit.longestStreak == 7)
    }

    // MARK: - completionPercentage

    @Test("completionPercentage is 0 with no check-ins")
    func completionPercentageEmpty() {
        let habit = makeHabit(duration: .oneWeek) // 7 days
        #expect(habit.completionPercentage == 0)
    }

    @Test("completionPercentage is 100 when fully complete")
    func completionPercentageFull() {
        let habit = makeHabit(duration: .oneWeek) // 7 days
        habit.checkIns = (0..<7).map { checkIn(daysAgo: $0, habit: habit) }
        #expect(habit.completionPercentage == 100)
    }

    @Test("completionPercentage is correct mid-way")
    func completionPercentageMidWay() {
        let habit = makeHabit(duration: .twoWeeks) // 14 days
        habit.checkIns = (0..<7).map { checkIn(daysAgo: $0, habit: habit) }
        #expect(habit.completionPercentage == 50)
    }

    @Test("completionPercentage can exceed 100 with more check-ins than duration")
    func completionPercentageOverflow() {
        let habit = makeHabit(duration: .oneWeek) // 7 days
        habit.checkIns = (0..<10).map { checkIn(daysAgo: $0, habit: habit) }
        #expect(habit.completionPercentage > 100)
    }

    // MARK: - isCompleted

    @Test("isCompleted is false with fewer check-ins than duration")
    func isCompletedFalse() {
        let habit = makeHabit(duration: .oneWeek)
        habit.checkIns = (0..<6).map { checkIn(daysAgo: $0, habit: habit) }
        #expect(habit.isCompleted == false)
    }

    @Test("isCompleted is true when check-ins reach duration")
    func isCompletedTrue() {
        let habit = makeHabit(duration: .oneWeek)
        habit.checkIns = (0..<7).map { checkIn(daysAgo: $0, habit: habit) }
        #expect(habit.isCompleted == true)
    }

    @Test("isCompleted is true with more check-ins than duration days")
    func isCompletedOverflow() {
        let habit = makeHabit(duration: .oneWeek)
        habit.checkIns = (0..<10).map { checkIn(daysAgo: $0, habit: habit) }
        #expect(habit.isCompleted == true)
    }
}
