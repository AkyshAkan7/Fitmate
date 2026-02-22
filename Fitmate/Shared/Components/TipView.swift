//
//  TipView.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/02/26.
//

import SwiftUI

struct TipView: View {
    let text: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Arrow
            Triangle()
                .fill(Color.blue)
                .frame(width: 12, height: 6)

            // Tip content
            Text(text)
                .body13Regular()
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(12)
        }
        .contentShape(Rectangle())
        .highPriorityGesture(
            TapGesture()
                .onEnded {
                    onDismiss?()
                }
        )
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        TipView(text: "Упражнения можно\nпоменять местами")

        TipView(text: "Single line tip")
    }
    .padding()
}
