//
//  CheckedInStateView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI

struct CheckedInStateView: View {
    @Binding var isCheckedIn: Bool
    @State private var flicker = false

    var body: some View {
        Group {
            if isCheckedIn {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 50))
            } else {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.gray)
                    .fontWeight(.light)
                    .font(.system(size: 50))
                    .onAppear {
                        flicker = true
                    }
                    .opacity(flicker ? 0.3 : 1.0)
                    .animation(.spring(duration: 1).repeatForever(autoreverses: true), value: flicker)
            }
        }
    }
}

#Preview {
    CheckedInStateView(isCheckedIn: .constant(true))
}
