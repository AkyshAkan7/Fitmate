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

    @State private var viewModel = ExerciseSelectionViewModel()
    @State private var selectedMuscleGroup: MuscleGroup = .chest
    @State private var selectedExercises: Set<UUID> = []
    @State private var selectedExercise: Exercise?

    private var isReplaceMode: Bool {
        mode == .replace
    }

    private var filteredExercises: [Exercise] {
        if selectedMuscleGroup == .custom {
            return customExerciseStore.exercises
        }
        return viewModel.exercises(for: selectedMuscleGroup)
    }

    private var allAvailableExercises: [Exercise] {
        viewModel.allExercises + customExerciseStore.exercises
    }

    private var chipItems: [MuscleGroup] {
        let server = viewModel.availableGroups
        if customExerciseStore.exercises.isEmpty {
            return server
        }
        return [.custom] + server
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            navigationBar

            // Content
            content

            // Bottom Button
            bottomButton
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
        .onChange(of: viewModel.availableGroups) { _, groups in
            // После загрузки: если выбранной группы нет в ответе — переключаемся на первую доступную
            if selectedMuscleGroup != .custom, !groups.contains(selectedMuscleGroup), let first = groups.first {
                selectedMuscleGroup = first
            }
        }
        // Switch to "My" tab when a new custom exercise is added
        .onChange(of: customExerciseStore.exercises.count) { oldCount, newCount in
            if newCount > oldCount {
                selectedMuscleGroup = .custom
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading where viewModel.exercisesByGroup.isEmpty:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message) where viewModel.exercisesByGroup.isEmpty:
            VStack(spacing: 12) {
                Text(message)
                    .body15Regular()
                    .foregroundStyle(Color.appGray)
                    .multilineTextAlignment(.center)
                Button("Повторить") {
                    Task { await viewModel.load() }
                }
                .body15Semibold()
                .foregroundStyle(.blue)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        default:
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    exerciseList

                    if selectedMuscleGroup != .custom {
                        createCustomLink
                    }
                }
                .padding(.top, 16)
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
