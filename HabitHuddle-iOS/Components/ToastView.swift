//
//  Toasts.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 26.06.25.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let icon: String?
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
            }
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color(.label).opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let icon: String?
    let duration: Double
    
    @State private var workItem: DispatchWorkItem?
    @State private var offsetY: CGFloat = 100
    
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    Spacer()
                    if isPresented {
                        ToastView(message: message, icon: icon)
                            .offset(y: offsetY)
                            .padding(.bottom, 50)
                            .transition(.identity)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: offsetY)
            )
            .onChange(of: isPresented) { oldValue, newValue in
                if newValue {
                    showToast()
                } else {
                    offsetY = 100
                }
            }
    }
    
    private func showToast() {
        // Cancel any existing work item
        workItem?.cancel()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            offsetY = 0
        }
        
        let task = DispatchWorkItem {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                offsetY = 200
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isPresented = false
            }
        }
        
        workItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
    }
}

extension View {
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        icon: String? = nil,
        duration: Double = 2.0
    ) -> some View {
        self.modifier(ToastModifier(
            isPresented: isPresented,
            message: message,
            icon: icon,
            duration: duration
        ))
    }
}

#Preview {
    ToastView(message: "Challenge accepted!", icon: nil)
}
