//
//  SwipeToDelete.swift
//  Fitmate
//
//  Created by Akan Akysh on 19/08/26.
//

import SwiftUI

struct SwipeToDelete<Content: View>: View {
    private let onDelete: () -> Void
    private let content: Content

    @State private var offset: CGFloat = 0
    @State private var isOpen = false

    private let buttonWidth: CGFloat = 76

    init(onDelete: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onDelete = onDelete
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(role: .destructive) {
                close()
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: buttonWidth)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
            }
            .buttonStyle(.plain)
            .opacity(offset < 0 ? 1 : 0)

            content
                .background(Color.white)
                .offset(x: offset)
                .highPriorityGesture(dragGesture)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: offset)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let base = isOpen ? -buttonWidth : 0
                offset = min(0, max(-buttonWidth - 20, base + value.translation.width))
            }
            .onEnded { value in
                let base = isOpen ? -buttonWidth : 0
                let projected = base + value.translation.width
                if projected < -buttonWidth / 2 {
                    offset = -buttonWidth
                    isOpen = true
                } else {
                    close()
                }
            }
    }

    private func close() {
        offset = 0
        isOpen = false
    }
}
