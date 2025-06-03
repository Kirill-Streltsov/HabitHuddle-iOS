//
//  FoundUserView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 03.06.25.
//

import SwiftUI

struct FoundUserView: View {
    
    let username: String
    let action: () -> ()
    
    var body: some View {
        HStack(spacing: 12) {

            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                )
            
            Text(username)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            SlimButton(title: "Add Friend") {
                action()
            }
            .buttonStyle(.plain)

        }
    }
}

#Preview {
    FoundUserView(username: "big_enthusiast") {}
}
