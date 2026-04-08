//
//  ConfirmWorkoutTemplateView.swift
//  Fitmate
//
//  Created by Akan Akysh on 03/03/26.
//

import SwiftUI

struct ConfirmWorkoutTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var templateStore: TemplateStore

    @State private var templateName: String
    @State private var exercises: [Exercise]

    init(templateName: String = "", exercises: [Exercise]) {
        _templateName = State(initialValue: templateName)
        _exercises = State(initialValue: exercises)
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    AppTextField(
                        "Например: Грудь и бицепс",
                        text: $templateName,
                        title: "Название"
                    )
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    exercisesList
                }
            }

            bottomButtons
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

                Text("Новый шаблон")
                    .headline24Semibold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }

    // MARK: - Exercises List

    private var exercisesList: some View {
        List {
            ForEach(exercises) { exercise in
                exerciseRow(exercise)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
            }
            .onMove { from, to in
                exercises.move(fromOffsets: from, toOffset: to)
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, .constant(.active))
        .scrollDisabled(true)
        .frame(height: CGFloat(exercises.count) * 72)
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        AppCell(
            icon: Image(systemName: "dumbbell"),
            title: exercise.name,
            subtitle: exercise.subtitle,
            trailingIcon: nil
        )
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            AppButton(title: "Изменить", type: .secondary) {
                dismiss()
            }

            AppButton(title: "Сохранить") {
                templateStore.add(name: templateName, exercises: exercises)
                router.popToRoot()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    ConfirmWorkoutTemplateView(
        templateName: "Грудь и бицепс",
        exercises: [
            Exercise(name: "Жим штанги", subtitle: "Subtitle", muscleGroup: .chest),
            Exercise(name: "Жим штанги 45 градусов", subtitle: "Subtitle", muscleGroup: .chest),
            Exercise(name: "Жим штанги", subtitle: "Subtitle", muscleGroup: .chest),
            Exercise(name: "Жим штанги 45 градусов", subtitle: "Subtitle", muscleGroup: .chest),
        ]
    )
    .environmentObject(Router())
}
