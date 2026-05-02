//
//  WorkoutConfirmView.swift
//  Fitmate
//
//  Created by Akan Akysh on 22/02/26.
//

import SwiftUI

// MARK: - Constants

private enum Layout {
    static let navBarHeight: CGFloat = 100
    static let topPadding: CGFloat = 16
    static let cellHeight: CGFloat = 64
    static let maxTipCellCount = 5
}

// MARK: - WorkoutConfirmView

struct WorkoutConfirmView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: Router
    @AppStorage(StorageKeys.hasSeenReorderTip) private var hasSeenReorderTip = false

    @State private var exercises: [Exercise]
    @State private var showTip = false

    init(exercises: [Exercise]) {
        _exercises = State(initialValue: exercises)
    }

    // MARK: - Computed Properties

    private var shouldShowTip: Bool {
        showTip && !hasSeenReorderTip
    }
    
    /// Позиция tip под последней ячейкой.
    /// Если ячеек больше 5 - показывается под 5-й ячейкой.
    private var tipYPosition: CGFloat {
        let cellCount = min(exercises.count, Layout.maxTipCellCount)
        return Layout.navBarHeight + Layout.topPadding + CGFloat(cellCount) * Layout.cellHeight
    }

    // MARK: - Actions

    private func dismissTip() {
        withAnimation {
            showTip = false
            hasSeenReorderTip = true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            navigationBar

            // Content
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
            .contentMargins(.top, 16, for: .scrollContent)
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))

            // Bottom Buttons
            bottomButtons
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !hasSeenReorderTip {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showTip = true
                    }
                }
            }
        }
        .overlay {
            if shouldShowTip {
                tipOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: shouldShowTip)
            }
        }
    }

    // MARK: - Tip Overlay

    private var tipOverlay: some View {
        GeometryReader { geometry in
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture(perform: dismissTip)

            TipView(text: "Упражнения можно\nпоменять местами", onDismiss: dismissTip)
                .scaleEffect(showTip ? 1 : 0.8)
                .opacity(showTip ? 1 : 0)
                .position(x: geometry.size.width / 2, y: tipYPosition)
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

                Text("Что делаем сегодня")
                    .headline24Semibold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }

    // MARK: - Exercise Row

    private func exerciseRow(_ exercise: Exercise) -> some View {
        AppCell(
            iconURL: exercise.imageURL,
            title: exercise.name,
            subtitle: exercise.subtitle,
            trailingIcon: nil
        )
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: 8) {
            AppButton(title: "Изменить", type: .secondary) {
                dismiss()
            }

            AppButton(title: "Начать") {
                router.navigate(to: .workoutSession(exercises: exercises))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#if DEBUG
#Preview {
    WorkoutConfirmView(exercises: [
        Exercise(name: "Жим штанги", subtitle: "Subtitle", muscleGroup: .previewChest),
        Exercise(name: "Жим штанги 45 градусов", subtitle: "Subtitle", muscleGroup: .previewChest),
        Exercise(name: "Жим штанги 90 градусов", subtitle: "Subtitle", muscleGroup: .previewChest),
    ])
    .environmentObject(Router())
}
#endif
