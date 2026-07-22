//
//  CreateCustomExerciseView.swift
//  Fitmate
//
//  Created by Akan Akysh on 08/04/26.
//

import SwiftUI
import SwiftData

struct CreateCustomExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var customExercises: [CustomExerciseLocal]

    @State private var exerciseName: String = ""

    private var trimmedName: String {
        exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isDuplicate: Bool {
        guard !trimmedName.isEmpty else { return false }
        let normalized = trimmedName.lowercased()
        return customExercises.contains {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalized
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            VStack(alignment: .leading, spacing: 0) {
                AppTextField(
                    text: $exerciseName,
                    title: "Название",
                    caption: isDuplicate
                        ? "Такое упражнение уже есть"
                        : "Например: Тяга в горизонтальном блоке"
                )
                .padding(.top, 16)

                Spacer()

                AppButton(title: "Добавить", isEnabled: !trimmedName.isEmpty && !isDuplicate) {
                    try? AppDependencies
                        .customExerciseRepository(context: modelContext)
                        .save(name: trimmedName)
                    dismiss()
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
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
}
