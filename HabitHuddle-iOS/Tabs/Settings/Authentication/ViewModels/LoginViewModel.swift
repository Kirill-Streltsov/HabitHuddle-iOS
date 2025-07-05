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
    
    @AppStorage("deviceToken") private var deviceToken: String = ""

    @Published var errorMessage: String = ""
    @Published var loadedHabits = [HabitDTO]()
    @Published var loadedUser = UserDTO(id: UUID(), username: "", name: "", createdAt: nil, updatedAt: nil)

    func loginUser(username: String, password: String) async {
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
            loadedUser = loginResponse.user
            await handleUserResponse()
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
    
    func handleGoogleSignIn() async {
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
                    body: GoogleTokenRequest(idToken: idToken, deviceToken: deviceToken),
                    responseType: LoginResponse.self,
                    isLoggingIn: true
                )
                TokenManager.token = loginResponse.token
                loadedUser = loginResponse.user
                await handleUserResponse()
            } catch {
                print("❌ Error: Failed to sign in with google. Couldn't authorize the google token: \(error)")
            }
        } catch {
            print("❌ Error: Failed to sign in with google. Didn't receive the token: \(error)")
        }
    }
    
    func handleAppleSignIn(appleToken: String, name: String) async {
        do {
            let loginResponse = try await NetworkManager.shared.request(
                endpoint: .appleSignIn(),
                method: .post,
                body: AppleAuthRequest(identityToken: appleToken, name: name, deviceToken: deviceToken),
                responseType: LoginResponse.self,
                isLoggingIn: true
            )
            TokenManager.token = loginResponse.token
            loadedUser = loginResponse.user
            await handleUserResponse()
        } catch {
            print("❌ Error: Failed to sign in with apple. Couldn't authorize the apple token: \(error)")
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
    
    func deleteHabits(with ids: [UUID]) async {
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
                    print("❌ Error: Failed to delete habit with ID \(id): \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteMyAccount() async -> Result<HTTPStatus, HHError> {
        do {
            let status = try await NetworkManager.shared.requestStatusCode(
                endpoint: .deleteMyself(),
                method: .delete
            )
            return .success(status)
        } catch {
            return .failure(.networkError(error))
        }
    }
    
    private func handleUserResponse() async {
        let codableHabitsResult = await getUserHabits()
        Helpers.handleResult(codableHabitsResult) { codableHabits in
            print("LOADED HABITS COUNT: \(loadedHabits.count)")
            loadedHabits = codableHabits
        } onFailure: { apiError in
            print("❌ Error: Could not load user habits: \(apiError.localizedDescription)")
        }
    }
}
