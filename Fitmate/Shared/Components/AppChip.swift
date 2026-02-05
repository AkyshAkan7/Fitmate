//
//  AppChip.swift
//  Fitmate
//
//  Created by Akan Akysh on 05/02/26.
//

import SwiftUI

struct AppChip: View {
    let title: String
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            Text(title)
                .body15Semibold()
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isSelected ? Color.yellow : Color.lightGray)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chip Group

struct AppChipGroup<T: Hashable>: View {
    let items: [T]
    @Binding var selected: T
    let titleFor: (T) -> String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.self) { item in
                AppChip(
                    title: titleFor(item),
                    isSelected: selected == item
                ) {
                    selected = item
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected = "Все"
        let options = ["Все", "Грудь", "Спина", "Ноги"]

        var body: some View {
            AppChipGroup(
                items: options,
                selected: $selected,
                titleFor: { $0 }
            )
            .padding()
        }
    }

    return PreviewWrapper()
}
