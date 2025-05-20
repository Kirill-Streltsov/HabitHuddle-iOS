//
//  HomeView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 20.05.25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query private var users: [User]

    var body: some View {
        ZStack {
            Color.white
            List {
                ForEach(users) { user in
                    Text(user.name)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
