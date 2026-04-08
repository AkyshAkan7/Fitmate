//
//  CreateCustomExerciseView.swift
//  Fitmate
//
//  Created by Akan Akysh on 08/04/26.
//

import SwiftUI

struct CreateCustomExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var customExerciseStore: CustomExerciseStore

    @State private var exerciseName: String = ""

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            VStack(alignment: .leading, spacing: 0) {
                AppTextField(
                    text: $exerciseName,
                    title: "Название",
                    caption: "Например: Тяга в горизонтальном блоке"
                )
                .padding(.top, 16)

                Spacer()

                AppButton(title: "Добавить", isEnabled: !exerciseName.trimmingCharacters(in: .whitespaces).isEmpty) {
                    customExerciseStore.add(name: exerciseName)
                    dismiss()
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

                Text("Свое упражнение")
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
    CreateCustomExerciseView()
        .environmentObject(CustomExerciseStore())
}
