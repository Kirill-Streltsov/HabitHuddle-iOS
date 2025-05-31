//
//  InputFormView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.05.25.
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        content()
            .padding()
            .background(.black.opacity(0.03))
            .cornerRadius(16)
            //.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
    }
}
