//
//  SlimButton.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct SlimButton: View {
    let title: String
    let color = Color.blue.opacity(0.9)
    let action: () -> ()
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(color)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    SlimButton(title: "Challenge") {}
}
