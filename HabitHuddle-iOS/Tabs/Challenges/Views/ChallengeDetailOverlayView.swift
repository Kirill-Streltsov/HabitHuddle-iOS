//
//  ChallengeDetailOverlayView.swift
//  HabitHuddle-iOS
//
//  Created by Kirill on 29.06.25.
//

import SwiftUI

struct ChallengeDetailOverlayView: View {
    let challenge: ChallengeDTO
    let namespace: Namespace.ID
    let onClose: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                ChallengeProgressCardView(challenge: challenge)
                    .matchedGeometryEffect(
                        id: challenge.id,
                        in: namespace,
                        isSource: false
                    )
                    .onTapGesture {
                        onClose()
                    }
                Divider()
                ChallengeCheckInsListView(challenge: challenge)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 28, height: 28)
                        .background(Color(.systemGray2))
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var previewNamespace
    ChallengeDetailOverlayView(challenge: ChallengeDTO(
        id: UUID(),
        initiatorHabitID: UUID(),
        receiverHabitID: UUID(),
        habitName: "",
        type: .competitive,
        startDate: .now,
        endDate: .now,
        status: .accepted,
        initiator: .init(
            user: .init(
                id: UUID(),
                username: "",
                name: "",
                createdAt: .now,
                updatedAt: .now),
            progress: 0,
            checkInCount: 0,
            plannedDays: 0),
        receiver: .init(
            user: .init(
                id: UUID(),
                username: "",
                name: "",
                createdAt: .now,
                updatedAt: .now),
            progress: 0,
            checkInCount: 0,
            plannedDays: 0)), namespace: previewNamespace, onClose: {})
}
