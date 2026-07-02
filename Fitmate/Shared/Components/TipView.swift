//
//  TipView.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/02/26.
//

import SwiftUI

enum TipArrow {
    case top
    case trailing
}

struct TipView: View {
    let text: String
    var arrow: TipArrow = .top
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        content
            .contentShape(Rectangle())
            .highPriorityGesture(
                TapGesture()
                    .onEnded {
                        onDismiss?()
                    }
            )
    }

    @ViewBuilder
    private var content: some View {
        switch arrow {
        case .top:
            VStack(spacing: 0) {
                Triangle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 6)

                bubble(alignment: .center)
            }
        case .trailing:
            HStack(spacing: 0) {
                bubble(alignment: .leading)

                TriangleRight()
                    .fill(Color.blue)
                    .frame(width: 6, height: 12)
            }
        }
    }

    private func bubble(alignment: TextAlignment) -> some View {
        Text(text)
            .body13Regular()
            .foregroundStyle(Color.white)
            .multilineTextAlignment(alignment)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(12)
    }
}

// MARK: - Triangle Shapes

/// Стрелка вверх (по центру сверху).
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

/// Стрелка вправо (по центру справа).
private struct TriangleRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
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
