//
//  ErrorText.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 18.05.25.
//

import SwiftUI

struct ErrorText: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundStyle(.red)
            .fontWeight(.regular)
    }
}

#Preview {
    ErrorText(text: "Something went wrong")
}
