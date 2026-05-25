//
//  SyncManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import Foundation
import SwiftData

@MainActor
final class SyncManager {
    static let shared = SyncManager()
    private let network: any NetworkManagerProtocol

    init(network: any NetworkManagerProtocol = NetworkManager.shared) {
        self.network = network
    }

    func getHabitsFromServer() async -> Result<[HabitDTO], HHError> {
        do {
            let fetchedHabits = try await network.request(
                endpoint: .getMyHabits(),
                method: .get,
                responseType: [HabitDTO].self)
            return .success(fetchedHabits)
        } catch {
            print("🔁 Couldn't fetch habits from the server. Failed to sync: \(error.localizedDescription)")
            return .failure(.networkError(error))
        }
    }

    func createHabitsOnTheServer(with habitPayloads: [HabitPayload]) async -> Result<[HabitDTO], HHError> {
        guard !habitPayloads.isEmpty else { return .success([]) }

        var createdHabits = [HabitDTO]()
        var failedHabitIDs = [UUID]()
        let network = network

        await withTaskGroup(of: (UUID, Result<HabitDTO, HHError>).self) { group in
            for habitPayload in habitPayloads {
                let habitID = habitPayload.id
                group.addTask {
                    do {
                        let created = try await network.request(
                            endpoint: .createHabit(),
                            method: .post,
                            body: habitPayload,
                            responseType: HabitDTO.self
                        )
                        return (habitID, .success(created))
                    } catch {
                        return (habitID, .failure(.networkError(error)))
                    }
                }
            }

            for await (id, result) in group {
                switch result {
                case .success(let dto):
                    createdHabits.append(dto)
                case .failure(let error):
                    failedHabitIDs.append(id)
                    print("❌ Error: Failed to create habit with ID \(id): \(error.localizedDescription)")
                }
            }
        }
        if failedHabitIDs.isEmpty {
            return .success(createdHabits)
        } else {
            print("⚠️ Some habits failed to be created: \(failedHabitIDs)")
            return .failure(.partialFailure(updated: createdHabits, failedIDs: failedHabitIDs))
        }
    }

    func updateHabitsOnTheServer(with habitPayloads: [HabitPayload]) async -> Result<[HabitDTO], HHError> {
        guard !habitPayloads.isEmpty else { return .success([]) }

        var updatedHabits = [HabitDTO]()
        var failedHabitIDs = [UUID]()
        let network = network

        await withTaskGroup(of: (UUID, Result<HabitDTO, HHError>).self) { group in
            for habitPayload in habitPayloads {
                let habitID = habitPayload.id
                group.addTask {
                    do {
                        let updated = try await network.request(
                            endpoint: .updateHabit(with: habitID),
                            method: .put,
                            body: habitPayload,
                            responseType: HabitDTO.self
                        )
                        return (habitID, .success(updated))
                    } catch {
                        return (habitID, .failure(.networkError(error)))
                    }
                }
            }

            for await (id, result) in group {
                switch result {
                case .success(let dto):
                    updatedHabits.append(dto)
                case .failure(let error):
                    failedHabitIDs.append(id)
                    print("❌ Error: Failed to update habit with ID \(id): \(error.localizedDescription)")
                }
            }
        }

        if failedHabitIDs.isEmpty {
            return .success(updatedHabits)
        } else {
            print("⚠️ Some habits failed to update: \(failedHabitIDs)")
            return .failure(.partialFailure(updated: updatedHabits, failedIDs: failedHabitIDs))
        }
    }

    func deleteHabitsOnTheServer(with ids: [UUID]) async -> Result<[HabitDTO], HHError> {
        guard !ids.isEmpty else { return .success([]) }

        var deletedHabits = [HabitDTO]()
        var failedIDs = [UUID]()
        let network = network

        await withTaskGroup(of: (UUID, Result<HabitDTO, HHError>).self) { group in
            for id in ids {
                group.addTask {
                    do {
                        let deleted = try await network.request(
                            endpoint: .deleteHabit(with: id),
                            method: .delete,
                            responseType: HabitDTO.self
                        )
                        return (id, .success(deleted))
                    } catch {
                        return (id, .failure(.networkError(error)))
                    }
                }
            }

            for await (id, result) in group {
                switch result {
                case .success(let dto):
                    deletedHabits.append(dto)
                case .failure(let error):
                    failedIDs.append(id)
                    print("❌ Error: Failed to delete habit with ID \(id): \(error.localizedDescription)")
                }
            }
        }

        if failedIDs.isEmpty {
            return .success(deletedHabits)
        } else {
            print("⚠️ Some habits failed to delete: \(failedIDs)")
            return .failure(.partialFailure(updated: deletedHabits, failedIDs: failedIDs))
        }
    }

    func flushPendingCheckIns() async {
        let pendingIDs = WidgetDataStore.loadPendingCheckInIDs()
        guard !pendingIDs.isEmpty else { return }

        let base = WidgetDataStore.loadBaseURL()
        guard let token = WidgetDataStore.loadToken() else { return }

        await withTaskGroup(of: Void.self) { group in
            for idString in pendingIDs {
                guard let id = UUID(uuidString: idString) else { continue }
                group.addTask {
                    guard let url = URL(string: "\(base)habits/\(id.uuidString)/toggle-checkin") else { return }
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    if let (_, response) = try? await URLSession.shared.data(for: request),
                       (response as? HTTPURLResponse)?.statusCode == 200 {
                        WidgetDataStore.removePendingCheckIn(habitID: id)
                    }
                }
            }
        }
    }

    func performFullSync(localHabits: [Habit], in modelContext: ModelContext) async {
        let serverResult = await getHabitsFromServer()
        guard case let .success(serverHabits) = serverResult else { return }

        // When local is empty, populate from server and stop; don't diff against empty set
        // (which would immediately re-delete everything we just saved).
        if localHabits.isEmpty && !serverHabits.isEmpty {
            saveHabits(serverHabits, in: modelContext)
            return
        }

        let serverIDs = Set(serverHabits.map { $0.id })
        let localIDs = Set(localHabits.map { $0.id })

        let toUpdate = localHabits.filter { serverIDs.contains($0.id) && $0.isSyncable }.map { $0.toPayload }
        let toCreate = localHabits.filter { !serverIDs.contains($0.id) && $0.isSyncable }.map { $0.toPayload }
        let toDelete = serverHabits.filter { !localIDs.contains($0.id) }.map { $0.id } + localHabits.filter { !$0.isSyncable }.map { $0.id }

        async let createResult = createHabitsOnTheServer(with: toCreate)
        async let updateResult = updateHabitsOnTheServer(with: toUpdate)
        async let deleteResult = deleteHabitsOnTheServer(with: toDelete)

        _ = await (createResult, updateResult, deleteResult)
    }

    func saveHabits(_ habits: [HabitDTO], in context: ModelContext) {
        for habit in habits {
            let _ = habit.saved(in: context)
        }
        context.saveOrLog()
    }
}
