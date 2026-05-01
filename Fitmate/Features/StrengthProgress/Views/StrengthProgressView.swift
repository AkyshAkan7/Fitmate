//
//  StrengthProgressView.swift
//  Fitmate
//
//  Created by Akan Akysh on 30/04/26.
//

import SwiftUI

struct StrengthProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router

    // Локальные группы для чипов. Подключим к данным позже.
    private let groups: [MuscleGroup] = [
        MuscleGroup(id: "chest", name: "Chest", nameRu: "Грудь"),
        MuscleGroup(id: "back", name: "Back", nameRu: "Спина"),
        MuscleGroup(id: "arms", name: "Arms", nameRu: "Руки"),
        MuscleGroup(id: "legs", name: "Legs", nameRu: "Ноги"),
        MuscleGroup(id: "shoulders", name: "Shoulders", nameRu: "Плечи"),
    ]

    // Мок-список упражнений по группам — пока что для проверки перехода.
    private let mockExercises: [(name: String, subtitle: String)] = [
        ("Жим штангой", "В наклоне на хуй"),
        ("Жим гантелей", "На наклонной скамье"),
        ("Разводка гантелей", "На горизонтальной скамье"),
    ]

    @State private var selectedGroup: MuscleGroup

    init() {
        _selectedGroup = State(initialValue: MuscleGroup(id: "chest", name: "Chest", nameRu: "Грудь"))
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(mockExercises, id: \.name) { exercise in
                        AppCell(
                            title: exercise.name,
                            subtitle: exercise.subtitle,
                            trailingIcon: Image("chevronRight")
                        ) {
                            router.navigate(to: .exerciseProgress(name: exercise.name, subtitle: exercise.subtitle))
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.primary)
                    }

                    Text("Прогресс силовых")
                        .headline24Semibold()
                }
                .padding(.horizontal, 16)

                AppChipGroup(
                    items: groups,
                    selected: $selectedGroup,
                    titleFor: { $0.displayName }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)

            Divider()
        }
    }
}

#Preview {
    StrengthProgressView()
}
