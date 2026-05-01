//
//  AppTextField.swift
//  Fitmate
//
//  Created by Akan Akysh on 03/03/26.
//

import SwiftUI

struct AppTextField: View {
    let title: String?
    let placeholder: String
    let caption: String?
    let autoFocus: Bool
    @Binding var text: String
    @FocusState private var isFocused: Bool

    init(
        _ placeholder: String = "",
        text: Binding<String>,
        title: String? = nil,
        caption: String? = nil,
        autoFocus: Bool = false
    ) {
        self.placeholder = placeholder
        self._text = text
        self.title = title
        self.caption = caption
        self.autoFocus = autoFocus
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .body13Regular()
                    .foregroundStyle(Color.appGray)
            }

            TextField(placeholder, text: $text)
                .body15Regular()
                .foregroundStyle(Color.appBlack)
                .padding(.horizontal, 12)
                .frame(height: 46)
                .background(Color.black.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused($isFocused)

            if let caption {
                Text(caption)
                    .body13Regular()
                    .foregroundStyle(Color.appGray)
            }
        }
        .task {
            // Небольшая задержка — иначе фокус не успевает примениться после push-перехода
            guard autoFocus else { return }
            try? await Task.sleep(for: .milliseconds(300))
            isFocused = true
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        AppTextField(
            "Placeholder",
            text: .constant(""),
            title: "Label",
            caption: "Caption"
        )

        AppTextField(
            "Введите имя",
            text: .constant("Akan"),
            title: "Имя"
        )

        AppTextField(
            "example@mail.com",
            text: .constant(""),
            title: "Email",
            caption: "На этот адрес придет подтверждение"
        )
    }
    .padding()
}
