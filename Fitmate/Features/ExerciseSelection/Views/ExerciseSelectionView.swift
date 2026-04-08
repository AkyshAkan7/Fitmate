//
//  ExerciseSelectionView.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/02/26.
//

import SwiftUI

// MARK: - ExerciseSelectionMode

enum ExerciseSelectionMode: Hashable {
    case workout
    case template(name: String)
}

// MARK: - ExerciseSelectionView

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var customExerciseStore: CustomExerciseStore

    var mode: ExerciseSelectionMode = .workout

    @State private var selectedMuscleGroup: MuscleGroup = .chest
    @State private var selectedExercises: Set<UUID> = []

    private let exercises: [Exercise] = [
        Exercise(name: "Жим штанги", subtitle: "Subtitle", muscleGroup: .chest),
        Exercise(name: "Жим штанги 45 градусов", subtitle: "Subtitle", muscleGroup: .chest),
        Exercise(name: "Жим штанги", subtitle: "Subtitle", muscleGroup: .chest),
        Exercise(name: "Жим штанги 45 градусов", subtitle: "Subtitle", muscleGroup: .chest),
        Exercise(name: "Жим штанги", subtitle: "Subtitle", muscleGroup: .chest),
        Exercise(name: "Тяга штанги", subtitle: "Subtitle", muscleGroup: .back),
        Exercise(name: "Подтягивания", subtitle: "Subtitle", muscleGroup: .back),
        Exercise(name: "Сгибания на бицепс", subtitle: "Subtitle", muscleGroup: .arms),
        Exercise(name: "Приседания", subtitle: "Subtitle", muscleGroup: .legs),
        Exercise(name: "Жим плечами", subtitle: "Subtitle", muscleGroup: .shoulders),
    ]

    private var filteredExercises: [Exercise] {
        if selectedMuscleGroup == .custom {
            return customExerciseStore.exercises
        }
        return exercises.filter { $0.muscleGroup == selectedMuscleGroup }
    }

    private var allAvailableExercises: [Exercise] {
        exercises + customExerciseStore.exercises
    }

    private var chipItems: [MuscleGroup] {
        if customExerciseStore.exercises.isEmpty {
            return MuscleGroup.filterCases
        }
        return [.custom] + MuscleGroup.filterCases
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            navigationBar

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Exercise List
                    exerciseList

                    // Create Custom Link
                    if selectedMuscleGroup != .custom {
                        createCustomLink
                    }
                }
                .padding(.top, 16)
            }

            // Bottom Button
            bottomButton
        }
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

                Text("Выбери упражнения")
                    .headline24Semibold()

                ScrollView(.horizontal, showsIndicators: false) {
                    AppChipGroup(
                        items: chipItems,
                        selected: $selectedMuscleGroup,
                        titleFor: { $0.rawValue }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        VStack(spacing: 0) {
            ForEach(filteredExercises) { exercise in
                AppCellControl(
                    icon: Image(systemName: "dumbbell"),
                    title: exercise.name,
                    subtitle: exercise.subtitle,
                    isSelected: Binding(
                        get: { selectedExercises.contains(exercise.id) },
                        set: { isSelected in
                            if isSelected {
                                selectedExercises.insert(exercise.id)
                            } else {
                                selectedExercises.remove(exercise.id)
                            }
                        }
                    )
                )
            }
        }
    }

    // MARK: - Create Custom Link

    private var createCustomLink: some View {
        VStack(spacing: 8) {
            Text("Не нашел то что надо?")
                .body15Regular()
                .foregroundStyle(Color.appGray)

            Button {
                router.navigate(to: .createCustomExercise)
            } label: {
                Text("Создать свое")
                    .body15Semibold()
                    .foregroundStyle(.blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(Color.appGray.opacity(0.5))
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        AppButton(title: "Готово", isEnabled: !selectedExercises.isEmpty) {
            let selected = allAvailableExercises.filter { selectedExercises.contains($0.id) }
            switch mode {
            case .workout:
                router.navigate(to: .workoutConfirm(exercises: selected))
            case .template(let name):
                router.navigate(to: .confirmTemplate(templateName: name, exercises: selected))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    ExerciseSelectionView()
        .environmentObject(Router())
        .environmentObject(CustomExerciseStore())
}
