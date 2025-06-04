//
//  SubmitButton.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 04.06.25.
//

import SwiftUI

struct SubmitButton: View {
    let title: String
    let color: Color
    let action: () -> ()
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundStyle(.white)
                .cornerRadius(12)
                .font(.headline)
        }
    }
}

#Preview {
    SubmitButton(title: "Submit", color: .orange, action: {})
}
