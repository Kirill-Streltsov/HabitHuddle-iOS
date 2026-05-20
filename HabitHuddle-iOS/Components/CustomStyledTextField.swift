//
//  CustomStyledTextField.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.05.25.
//

import SwiftUI

struct CustomStyledTextField: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.clear, lineWidth: 1)
            )
            .font(.body)
            .foregroundStyle(.primary)
    }
}
