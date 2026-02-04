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
        }
    }

    private var textColor: Color {
        switch type {
        case .primary:
            return isEnabled ? .white : .white.opacity(0.35)
        case .secondary:
            return isEnabled ? .appBlack : .appBlack.opacity(0.35)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AppButton(title: "Сохранить", type: .primary, isEnabled: true) { }
        AppButton(title: "Сохранить", type: .primary, isEnabled: false) { }
        AppButton(title: "Сохранить", type: .secondary, isEnabled: true) { }
        AppButton(title: "Сохранить", type: .secondary, isEnabled: false) { }
    }
    .padding(.horizontal, 16)
}
