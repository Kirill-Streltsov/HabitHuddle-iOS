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
        guard let url = fileURL, FileManager.default.fileExists(atPath: url.path) else { return }
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
        print("🔁 SyncManager: adding operation: \(op.action)")
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
        
        let deleteHabitOperations = operations.filter { $0.action == .delete }
        for op in deleteHabitOperations {
            operations.removeAll { $0.habitID == op.habitID && $0.action != .delete }
        }
        
        for op in operations {
            do {
                let habitStore = HabitStore(modelContainer: context.container)
                let payload = try await habitStore.getPayload(for: op.habitID)
                try await perform(op, with: payload)
                remove(op)
            } catch {
                print("🔁 Retry failed for operation \(op.id): \(error)")
            }
        }
    }

    /// Step 2: Perform network sync separately
    private func perform(_ op: SyncOperation, with payload: HabitPayload?) async throws {
        switch op.action {
        case .checkIn:
            _ = try await NetworkManager.shared.requestStatusCode(
                endpoint: .checkIntoHabit(with: op.habitID),
                method: .post
            )
            print("✅ Synced: Check in for \(op.habitID)")

        case .delete:
            _ = try await NetworkManager.shared.requestStatusCode(
                endpoint: .deleteHabit(with: op.habitID),
                method: .delete
            )
            print("✅ Synced: Delete \(op.habitID)")

        case .create:
            guard let payload else { throw SyncError.payloadMissing }
            _ = try await NetworkManager.shared.request(
                endpoint: .createHabit(),
                method: .post,
                body: payload,
                responseType: HabitDTO.self
            )
            print("✅ Synced: Create \(op.habitID)")

        case .update:
            guard let payload else { throw SyncError.payloadMissing }
            _ = try await NetworkManager.shared.request(
                endpoint: .updateHabit(with: op.habitID),
                method: .put,
                body: payload,
                responseType: HabitDTO.self
            )
            print("✅ Synced: Update \(op.habitID)")
        }
    }
}

enum SyncError: Error {
    case payloadMissing
}
