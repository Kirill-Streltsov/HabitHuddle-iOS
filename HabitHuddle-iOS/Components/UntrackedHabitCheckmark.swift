//
//  UntrackedHabitCheckmark.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 23.05.25.
//

import SwiftUI

struct UntrackedHabitCheckmark: View {
    @State private var flicker = false
    
    var body: some View {
        
        Image(systemName: "checkmark.circle")
            .fontWeight(.light)
            .opacity(flicker ? 0.6 : 1.0)
            .animation(.spring(duration: 1).repeatForever(autoreverses: true), value: flicker)
            .onAppear {
                flicker = true
                
            }
    }
}
#Preview {
    UntrackedHabitCheckmark()
}
