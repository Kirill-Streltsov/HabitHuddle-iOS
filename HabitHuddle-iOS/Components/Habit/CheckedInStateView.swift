//
//  CheckedInStateView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI

struct CheckedInStateView: View {
    let isCheckedIn: Bool
    let fontSize: CGFloat
    let shouldFlicker: Bool

    var body: some View {
        Group {
            if isCheckedIn {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: fontSize))
            } else {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.gray)
                    .fontWeight(.light)
                    .font(.system(size: fontSize))
                    .flickering(shouldFlicker: shouldFlicker)
            }
        }
    }
}

#Preview {
    CheckedInStateView(isCheckedIn: true, fontSize: 50, shouldFlicker: true)
}
