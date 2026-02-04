//
//  StatsCardView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

struct StatsCardView: View {
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .body15Regular()
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .body13Regular()
                        .foregroundColor(.appGray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appGray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.lightGray)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 0) {
        StatsCardView(
            title: "Прогресс силовых",
            subtitle: "Упражнений: 12"
        )

        Divider()
            .padding(.horizontal, 16)

        StatsCardView(
            title: "История тренировок",
            subtitle: "Завершено тренировок: 56"
        )
    }
    .cornerRadius(16)
    .padding(.horizontal, 16)
}
