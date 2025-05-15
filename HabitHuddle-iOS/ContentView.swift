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
            VStack {
                TextField(text: $email) {
                    Text("Email")
                }
                TextField(text: $password) {
                    Text("Password")
                }
            }
            .padding(.horizontal)
            Button {

            } label: {
                Text("Register")
            }
        }
    }
}

#Preview {
    ContentView()
}
