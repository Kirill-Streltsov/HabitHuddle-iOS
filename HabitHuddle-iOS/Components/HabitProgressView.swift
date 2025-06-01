//
//  HabitProgressView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct HabitProgressView: View {
    
    let fillingWidth: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = 4
    var color: Color = Color.gray.opacity(0.3)
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(color)
                .frame(height: height)
                .cornerRadius(cornerRadius)

            Rectangle()
                .fill(Color.green)
                .frame(width: fillingWidth, height: height)
                .cornerRadius(cornerRadius)
        }
    }
}

#Preview {
    HabitProgressView(fillingWidth: 50, height: 50)
}
