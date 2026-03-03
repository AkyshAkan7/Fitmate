//
//  CreateWorkoutTemplateView.swift
//  Fitmate
//
//  Created by Akan Akysh on 03/03/26.
//

import SwiftUI

struct CreateWorkoutTemplateView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var templateName: String = ""

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            VStack(alignment: .leading, spacing: 0) {
                AppTextField(
                    "Например: Грудь и бицепс",
                    text: $templateName,
                    title: "Название"
                )
                .padding(.top, 16)

                Spacer()

                AppButton(title: "Добавить упражнения") {
                    // TODO: Navigate to exercise selection
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.primary)
                }

                Text("Новый шаблон")
                    .headline24Semibold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }
}

#Preview {
    CreateWorkoutTemplateView()
}
