//
//  SyncManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import Foundation
import SwiftData

final class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    private let filename = "sync_queue.json"
    private var fileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(filename)
    }
    
    private(set) var operations: [SyncOperation] = []
    
    private init() {
        load()
    }
    
    // MARK: - Persistence
    
    private func load() {
        guard let url = fileURL,
              FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            operations = try JSONDecoder().decode([SyncOperation].self, from: data)
        } catch {
            print("❌ Failed to load sync queue: \(error.localizedDescription)")
        }
    }
    
    private func save() {
        guard let url = fileURL else { return }
        
        do {
            let data = try JSONEncoder().encode(operations)
            try data.write(to: url)
        } catch {
            print("❌ Failed to save sync queue: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public API
    
    func add(_ op: SyncOperation) {
        operations.append(op)
        save()
    }
    
    func remove(_ op: SyncOperation) {
        operations.removeAll { $0.id == op.id }
        save()
    }
    
    func clear() {
        operations.removeAll()
        save()
    }
    
    func retry(from context: ModelContext) async {
        for op in operations {
            do {
                try await perform(op, from: context)
                remove(op)
            } catch {
                print("🔁 Retry failed for operation \(op.id): \(error)")
            }
        }
    }
    
    private func perform(_ op: SyncOperation, from context: ModelContext? = nil) async throws {
        let fetchDescriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == op.habitID })
        switch op.action {
        case .checkIn:
            _ = try await NetworkingManager.shared.requestStatusCode(endpoint: .checkIntoHabit(with: op.habitID), method: .post)
            print("✅ Successful sync for \(op.habitID). Operation: Check in")
        case .delete:
            _ = try await NetworkingManager.shared.requestStatusCode(endpoint: .deleteHabit(with: op.habitID), method: .delete)
            print("✅ Successful sync for \(op.habitID). Operation: Delete")
        case .update:
            if let habit = try? context?.fetch(fetchDescriptor).first {
                print("FOUND HABIT TO UPDATE: \(habit.name)")
                let payload = HabitPayload(
                    id: habit.id,
                    name: habit.name,
                    description: habit.habitDescription,
                    duration: habit.duration.rawValue,
                    reminderTime: habit.reminderTime
                )
                let _ = try await NetworkingManager.shared.request(
                    endpoint: .updateHabit(with: habit.id),
                    method: .put,
                    body: payload,
                    responseType: CodableHabit.self
                )
                print("✅ Successful sync for \(op.habitID). Operation: Update")
            }
        case .create:
            if let habit = try? context?.fetch(fetchDescriptor).first {
                let payload = HabitPayload(
                    id: habit.id,
                    name: habit.name,
                    description: habit.habitDescription,
                    duration: habit.duration.rawValue,
                    reminderTime: habit.reminderTime
                )
                let _ = try await NetworkingManager.shared.request(
                    endpoint: .createHabit(),
                    method: .post,
                    body: payload,
                    responseType: CodableHabit.self
                )
                print("✅ Successful sync for \(op.habitID). Operation: Create")
            }
        }
    }
}
