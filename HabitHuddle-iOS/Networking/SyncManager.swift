//
//  SyncManager.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import Foundation

final class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    func getHabitsFromServer() async -> Result<[HabitDTO], HHError> {
        do {
            let fetchedHabits = try await NetworkManager.shared.request(
                endpoint: .getMyHabits(),
                method: .get,
                responseType: [HabitDTO].self)
            return .success(fetchedHabits)
        } catch {
            print("🔁 Couldn't fetch habits from the server. Failed to sync: \(error.localizedDescription)")
            return .failure(.networkError(error))
        }
    }
    
    func createHabitsOnTheServer(with habits: [Habit]) async -> Result<[HabitDTO], HHError> {
        guard !habits.isEmpty else { return .success([]) }
        
        var createdHabits = [HabitDTO]()
        var failedHabitIDs = [UUID]()
        
        await withTaskGroup(of: (UUID, Result<HabitDTO, HHError>).self) { group in
            for habit in habits {
                group.addTask {
                    
                    let payload = habit.toPayload
                    
                    do {
                        let created = try await NetworkManager.shared.request(
                            endpoint: .createHabit(),
                            method: .post,
                            body: payload,
                            responseType: HabitDTO.self
                        )
                        return (habit.id, .success(created))
                    } catch {
                        return (habit.id, .failure(.networkError(error)))
                    }
                }
            }
            
            for await (id, result) in group {
                switch result {
                case .success(let dto):
                    createdHabits.append(dto)
                case .failure(let error):
                    failedHabitIDs.append(id)
                    print("❌ Failed to create habit with ID \(id): \(error.localizedDescription)")
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
    
    func updateHabitsOnTheServer(with habits: [Habit]) async -> Result<[HabitDTO], HHError> {
        guard !habits.isEmpty else { return .success([]) }

        var updatedHabits = [HabitDTO]()
        var failedHabitIDs = [UUID]()

        await withTaskGroup(of: (UUID, Result<HabitDTO, HHError>).self) { group in
            for habit in habits {
                group.addTask {
                    let payload = habit.toPayload

                    do {
                        let updated = try await NetworkManager.shared.request(
                            endpoint: .updateHabit(with: habit.id),
                            method: .put,
                            body: payload,
                            responseType: HabitDTO.self
                        )
                        return (habit.id, .success(updated))
                    } catch {
                        return (habit.id, .failure(.networkError(error)))
                    }
                }
            }

            for await (id, result) in group {
                switch result {
                case .success(let dto):
                    updatedHabits.append(dto)
                case .failure(let error):
                    failedHabitIDs.append(id)
                    print("❌ Failed to update habit with ID \(id): \(error.localizedDescription)")
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

        await withTaskGroup(of: (UUID, Result<HabitDTO, HHError>).self) { group in
            for id in ids {
                group.addTask {
                    do {
                        let deleted = try await NetworkManager.shared.request(
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
                    print("❌ Failed to delete habit with ID \(id): \(error.localizedDescription)")
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
    
    func performFullSync(localHabits: [Habit]) async {
        let serverResult = await getHabitsFromServer()
        guard case let .success(serverHabits) = serverResult else { return }

        let serverIDs = Set(serverHabits.map { $0.id })
        let localIDs = Set(localHabits.map { $0.id })

        let toUpdate = localHabits.filter { serverIDs.contains($0.id) }
        let toCreate = localHabits.filter { !serverIDs.contains($0.id) }
        let toDelete = serverHabits.filter { !localIDs.contains($0.id) }.map { $0.id }

        async let createResult = createHabitsOnTheServer(with: toCreate)
        async let updateResult = updateHabitsOnTheServer(with: toUpdate)
        async let deleteResult = deleteHabitsOnTheServer(with: toDelete)
        
        // Await all results at once
        _ = await (createResult, updateResult, deleteResult)
    }
}
