//
//  AppButton.swift
//  Fitmate
//
//  Created by Akan Akysh on 05/02/26.
//

import SwiftUI

enum AppButtonType {
    case primary
    case secondary
    case text
    case destructive
}

struct AppButton: View {
    let title: String
    var type: AppButtonType = .primary
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .body15Semibold()
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(backgroundColor)
                .cornerRadius(16)
        }
        .disabled(!isEnabled)
    }

    private var backgroundColor: Color {
        switch type {
        case .primary:
            return .appBlack
        case .secondary:
            return .lightGray
        case .text, .destructive:
            return .clear
        }
    }

    private var textColor: Color {
        switch type {
        case .primary:
            return isEnabled ? .white : .white.opacity(0.35)
        case .secondary:
            return isEnabled ? .appBlack : .appBlack.opacity(0.35)
        case .text:
            return isEnabled ? .appBlack : .appGray
        case .destructive:
            return isEnabled ? .red : .red.opacity(0.35)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AppButton(title: "Сохранить", type: .primary, isEnabled: true) { }
        AppButton(title: "Сохранить", type: .primary, isEnabled: false) { }
        AppButton(title: "Сохранить", type: .secondary, isEnabled: true) { }
        AppButton(title: "Сохранить", type: .secondary, isEnabled: false) { }
        AppButton(title: "Подробнее", type: .text, isEnabled: true) { }
        AppButton(title: "Удалить аккаунт", type: .destructive, isEnabled: true) { }
    }
    .padding(.horizontal, 16)
}
