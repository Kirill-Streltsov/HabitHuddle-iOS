//
//  HabitProgressView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 01.06.25.
//

import SwiftUI

struct HabitProgressView: View {
    
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = 4
    var color: Color = Color.gray.opacity(0.3)
    
    let calculatedProgress: Double
    @State private var progress: Double = 0.0
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(color)
                .frame(width: width, height: height)
                .cornerRadius(cornerRadius)

            Rectangle()
                .fill(Color.green)
                .frame(width: width * CGFloat(progress), height: height)
                .cornerRadius(cornerRadius)
        }
        .onAppear {
            withAnimation(.easeOut) {
                progress = calculatedProgress
            }
        }
    }
}

#Preview {
    HabitProgressView(width: 50, height: 50, calculatedProgress: 0.5)
}
