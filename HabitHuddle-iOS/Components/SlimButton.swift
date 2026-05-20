//
//  SlimButton.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 02.06.25.
//

import SwiftUI

struct SlimButton: View {
    let title: LocalizedStringKey
    let color: Color
    let action: () -> ()

    init(title: LocalizedStringKey, color: Color = .blue.opacity(0.9), action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(color)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    SlimButton(title: "Challenge", color: .pink) {}
}
