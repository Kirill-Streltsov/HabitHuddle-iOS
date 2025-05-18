//
//  ContentView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 14.05.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack {
            Button("SEND TO SERVER") {
                Task {
                    await sendLoginRequest()
                }
            }
            VStack {
                TextField(text: $email) {
                    Text("Email")
                }
                TextField(text: $password) {
                    Text("Password")
                }
            }
            .padding(.horizontal)
        }
    }
    
    func sendLoginRequest() async {
        guard let url = URL(string: "http://localhost:8080/api/auth/register") else {
            print("Invalid URL")
            return
        }

        let body: [String: String] = [
            "username": "new user",
            "password": "secret42"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                print("Server error")
                return
            }

            // Try to print the response JSON
            if let json = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let jsonString = String(data: prettyData, encoding: .utf8) {
                print("Response JSON:\n\(jsonString)")
            } else {
                print("Invalid or empty response")
            }
        } catch {
            print("Request failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
