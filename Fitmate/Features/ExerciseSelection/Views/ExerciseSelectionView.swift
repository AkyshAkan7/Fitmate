//
//  ExerciseSelectionView.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/02/26.
//

import SwiftUI

// MARK: - ExerciseSelectionMode

enum ExerciseSelectionMode: Hashable {
    // Main workout flow
    case workout
    // Add template flow
    case template(name: String)
    // Change exercise flow
    case replace
}

// MARK: - ExerciseSelectionView

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var customExerciseStore: CustomExerciseStore

    var mode: ExerciseSelectionMode = .workout

    @State private var selectedMuscleGroup: MuscleGroup = .chest
    @State private var selectedExercises: Set<UUID> = []
    @State private var selectedExercise: Exercise?

    private var isReplaceMode: Bool {
        mode == .replace
    }

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
        // Switch to "My" tab when a new custom exercise is added
        .onChange(of: customExerciseStore.exercises.count) { oldCount, newCount in
            if newCount > oldCount {
                selectedMuscleGroup = .custom
            }
        }
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

                Text(isReplaceMode ? "Выбери упражнение" : "Выбери упражнения")
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
                    style: isReplaceMode ? .radio : .checkbox,
                    isSelected: isSelectedBinding(for: exercise)
                )
            }
        }
    }

    private func isSelectedBinding(for exercise: Exercise) -> Binding<Bool> {
        Binding(
            get: {
                isReplaceMode
                    ? selectedExercise?.id == exercise.id
                    : selectedExercises.contains(exercise.id)
            },
            set: { isSelected in
                if isReplaceMode {
                    selectedExercise = isSelected ? exercise : nil
                } else {
                    toggleExerciseSelection(exercise, isSelected: isSelected)
                }
            }
        )
    }

    private func toggleExerciseSelection(_ exercise: Exercise, isSelected: Bool) {
        if isSelected {
            selectedExercises.insert(exercise.id)
        } else {
            selectedExercises.remove(exercise.id)
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
        let isEnabled = isReplaceMode ? selectedExercise != nil : !selectedExercises.isEmpty
        let title = isReplaceMode ? "Заменить" : "Готово"

        return AppButton(title: title, isEnabled: isEnabled) {
            switch mode {
            case .workout:
                let selected = allAvailableExercises.filter { selectedExercises.contains($0.id) }
                router.navigate(to: .workoutConfirm(exercises: selected))
            case .template(let name):
                let selected = allAvailableExercises.filter { selectedExercises.contains($0.id) }
                router.navigate(to: .confirmTemplate(templateName: name, exercises: selected))
            case .replace:
                if let exercise = selectedExercise {
                    router.onExerciseReplace?(exercise)
                    router.onExerciseReplace = nil
                    router.pop()
                }
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
