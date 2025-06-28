//
//  LoginViewModel.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 19.05.25.
//

import SwiftData
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    let appState: AppState
    let userManager: LocalUserManager

    @Published var errorMessage: String = ""

    init(appState: AppState, userManager: LocalUserManager) {
        self.appState = appState
        self.userManager = userManager
    }

    func loginUser(username: String, password: String, using context: ModelContext) async {
        let base64Login = makeBase64Login(username: username, password: password)

        do {
            let headers = ["Authorization": "Basic \(base64Login)"]
            let loginResponse = try await NetworkManager.shared.request(
                endpoint: .login(),
                method: .post,
                headers: headers,
                responseType: LoginResponse.self,
                isLoggingIn: true
            )

            TokenManager.token = loginResponse.token
            let user = loginResponse.user
            userManager.profile = LocalUser(
                id: user.id,
                username: user.username,
                name: user.name,
                isSignedInToServer: true)
            handleUserResponse(user: user, in: context)
        } catch {
            if let apiError = error as? HHError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = "Something went wrong. Please try again."
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.errorMessage = ""
            }
        }
    }
    
    func handleGoogleSignIn(using context: ModelContext) async {
        // Wrap the callback-based Google sign-in into async/await
        do {
            let idToken = try await withCheckedThrowingContinuation { continuation in
                GoogleAuthManager.shared.signIn { result in
                    switch result {
                    case .success(let idToken):
                        continuation.resume(returning: idToken)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                        print("❌ Error: Failed to sign in with google")
                    }
                }
            }
            do {
                let loginResponse = try await NetworkManager.shared.request(
                    endpoint: .googleSignIn(),
                    method: .post,
                    body: GoogleTokenRequest(idToken: idToken),
                    responseType: LoginResponse.self,
                    isLoggingIn: true
                )
                let user = loginResponse.user
                userManager.profile = LocalUser(
                    id: user.id,
                    username: user.username,
                    name: user.name,
                    isSignedInToServer: true)
                TokenManager.token = loginResponse.token
                handleUserResponse(user: user, in: context)
            } catch {
                print("❌ Error: Failed to sign in with google. Couldn't authorize the google token.")
            }
        } catch {
            print("❌ Error: Failed to sign in with google. Didn't receive the token.")
        }
    }

    private func makeBase64Login(username: String, password: String) -> String {
        let loginString = "\(username):\(password)"
        if let data = loginString.data(using: .utf8) {
            return data.base64EncodedString()
        } else {
            fatalError("Couldn't encode your username or password")
        }
    }

    func saveUser(_ user: UserDTO, in context: ModelContext) {
        let descriptor = FetchDescriptor<User>()

        do {
            let existingUsers = try context.fetch(descriptor)

            // Delete all previous instances
            for user in existingUsers {
                context.delete(user)
            }

            let newUser = User(
                id: user.id,
                username: user.username,
                name: user.name,
                createdAt: user.createdAt,
                updatedAt: user.updatedAt
            )
            context.insert(newUser)
            try? context.save()
            appState.isAuthenticated = true
        } catch {
            fatalError("Couldn't save user's information")
        }
    }

    func getUserHabits() async -> Result<[HabitDTO], HHError> {
        do {
            let habits = try await NetworkManager.shared.request(
                endpoint: .getMyHabits(),
                method: .get,
                responseType: [HabitDTO].self
            )
            return .success(habits)
        } catch {
            return .failure(.networkError(error))
        }
    }
    
    private func handleUserResponse(user: UserDTO, in context: ModelContext) {
        Task {
            print("TOKEN: \(String(describing: TokenManager.token))")
            let codableHabitsResult = await getUserHabits()
            Helpers.handleResult(codableHabitsResult) { codableHabits in
                let localHabits = fetchLocalHabits(from: context)
                if codableHabits.isEmpty && !localHabits.isEmpty {
                    Task {
                        await SyncManager.shared.performFullSync(localHabits: localHabits, in: context)
                    }
                }
                saveHabitsLocally(codableHabits, in: context)
                saveUser(user, in: context)
                print("TOKEN: \(TokenManager.token)")
            } onFailure: { apiError in
                print("❌ Error: Could not load user habits: \(apiError.localizedDescription)")
            }
        }
    }
    
    private func fetchLocalHabits(from context: ModelContext) -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        do {
            let habits = try context.fetch(descriptor)
            return habits
        } catch {
            print("❌ Error: Couldn't fetch local habits: \(error.localizedDescription)")
            return []
        }
    }

    private func saveHabitsLocally(_ codableHabits: [HabitDTO], in context: ModelContext) {
        for codableHabit in codableHabits {
            // Skip if habit with same ID already exists
            if habitExists(withId: codableHabit.id, in: context) {
                continue
            }

            let habit = codableHabit.toSwiftData()

            codableHabit.checkIns?.forEach { _ in
                let checkIn = HabitCheckIn(habit: habit)
                context.insert(checkIn)
            }

            context.insert(habit)
        }
        try? context.save()
    }
    
    private func habitExists(withId id: UUID, in context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == id })
        return (try? context.fetchCount(descriptor)) ?? 0 > 0
    }
}
