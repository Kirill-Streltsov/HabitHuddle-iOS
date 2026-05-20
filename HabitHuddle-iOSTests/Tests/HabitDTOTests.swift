//
//  HabitDTOTests.swift
//  HabitHuddle-iOSTests
//

import Testing
import Foundation
@testable import HabitHuddle_iOS

@Suite("HabitDTO extensions")
struct HabitDTOTests {

    // MARK: - Helpers

    private func makeDTO(
        duration: HabitDuration = .twoWeeks,
        checkIns: [HabitCheckInDTO]? = []
    ) -> HabitDTO {
        HabitDTO(
            id: UUID(),
            user: LightweightUser(id: UUID()),
            name: "Test",
            description: "",
            category: "",
            duration: duration,
            reminderTime: nil,
            createdAt: Date(),
            updatedAt: Date(),
            checkIns: checkIns,
            challenges: nil,
            icon: nil
        )
    }

    private func checkInDTO(daysAgo: Int) -> HabitCheckInDTO {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        return HabitCheckInDTO(date: date, habit: LightweightHabit(id: UUID()))
    }

    // MARK: - completionPercentage

    @Test("completionPercentage is 0 with nil check-ins")
    func completionNilCheckIns() {
        let dto = makeDTO(checkIns: nil)
        #expect(dto.completionPercentage == 0)
    }

    @Test("completionPercentage is 0 with empty check-ins")
    func completionEmptyCheckIns() {
        let dto = makeDTO(checkIns: [])
        #expect(dto.completionPercentage == 0)
    }

    @Test("completionPercentage is 100 for one-week habit with 7 check-ins")
    func completionFull() {
        let dto = makeDTO(duration: .oneWeek, checkIns: (0..<7).map { checkInDTO(daysAgo: $0) })
        #expect(dto.completionPercentage == 100)
    }

    @Test("completionPercentage is 50 for two-week habit with 7 check-ins")
    func completionHalf() {
        let dto = makeDTO(duration: .twoWeeks, checkIns: (0..<7).map { checkInDTO(daysAgo: $0) })
        #expect(dto.completionPercentage == 50)
    }

    // MARK: - isCompleted

    @Test("isCompleted false when nil check-ins")
    func isCompletedNil() {
        let dto = makeDTO(checkIns: nil)
        #expect(dto.isCompleted == false)
    }

    @Test("isCompleted false when not enough check-ins")
    func isCompletedFalse() {
        let dto = makeDTO(duration: .oneWeek, checkIns: (0..<6).map { checkInDTO(daysAgo: $0) })
        #expect(dto.isCompleted == false)
    }

    @Test("isCompleted true when check-ins reach duration days")
    func isCompletedTrue() {
        let dto = makeDTO(duration: .oneWeek, checkIns: (0..<7).map { checkInDTO(daysAgo: $0) })
        #expect(dto.isCompleted == true)
    }

    // MARK: - isCheckedInToday

    @Test("isCheckedInToday false with nil check-ins")
    func checkedInTodayNil() {
        let dto = makeDTO(checkIns: nil)
        #expect(dto.isCheckedInToday == false)
    }

    @Test("isCheckedInToday false when last check-in was yesterday")
    func checkedInTodayFalse() {
        let dto = makeDTO(checkIns: [checkInDTO(daysAgo: 1)])
        #expect(dto.isCheckedInToday == false)
    }

    @Test("isCheckedInToday true when there is a check-in today")
    func checkedInTodayTrue() {
        let dto = makeDTO(checkIns: [checkInDTO(daysAgo: 0)])
        #expect(dto.isCheckedInToday == true)
    }

    // MARK: - longestStreak

    @Test("longestStreak is 0 with nil check-ins")
    func longestStreakNil() {
        let dto = makeDTO(checkIns: nil)
        #expect(dto.longestStreak == 0)
    }

    @Test("longestStreak is 0 with empty check-ins")
    func longestStreakEmpty() {
        let dto = makeDTO(checkIns: [])
        #expect(dto.longestStreak == 0)
    }

    @Test("longestStreak finds the longest run")
    func longestStreakFindsMax() {
        let checkIns = [
            checkInDTO(daysAgo: 10),
            checkInDTO(daysAgo: 9),
            // gap
            checkInDTO(daysAgo: 5),
            checkInDTO(daysAgo: 4),
            checkInDTO(daysAgo: 3),
        ]
        let dto = makeDTO(checkIns: checkIns)
        #expect(dto.longestStreak == 3)
    }

    @Test("longestStreak with single check-in")
    func longestStreakSingle() {
        let dto = makeDTO(checkIns: [checkInDTO(daysAgo: 3)])
        #expect(dto.longestStreak == 1)
    }
}
