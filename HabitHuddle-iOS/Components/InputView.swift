//
//  InputView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: LocalizedStringResource
    let placeholder: LocalizedStringResource
    var isSecureField = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundStyle(Color(.darkGray))
                .fontWeight(.semibold)

            if isSecureField {
                SecureField(text: $text) {
                    Text(placeholder)
                }
                .font(.system(size: 14))
            } else {
                TextField(text: $text) {
                    Text(placeholder)
                }
                .font(.system(size: 14))
            }
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: .username, placeholder: .enterYourUsername)
}
