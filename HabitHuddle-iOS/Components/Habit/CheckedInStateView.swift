//
//  CheckedInStateView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI

struct CheckedInStateView: View {
    let isOn: Bool
    let fontSize: CGFloat
    let shouldFlicker: Bool
    let iconOn: String
    let iconOff: String
    let color: Color

    var body: some View {
        Group {
            if isOn {
                Image(systemName: iconOn)
                    .foregroundStyle(color)
                    .font(.system(size: fontSize))
            } else {
                Image(systemName: iconOff)
                    .foregroundStyle(.gray)
                    .fontWeight(.light)
                    .font(.system(size: fontSize))
                    .flickering(shouldFlicker: shouldFlicker)
            }
        }
    }
}

#Preview {
    CheckedInStateView(isOn: true, fontSize: 50, shouldFlicker: true, iconOn: "", iconOff: "", color: .green)
}
