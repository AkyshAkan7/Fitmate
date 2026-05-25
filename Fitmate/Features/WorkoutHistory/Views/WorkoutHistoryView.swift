//
//  WorkoutHistoryView.swift
//  Fitmate
//
//  Created by Akan Akysh on 12/05/26.
//

import SwiftUI
import SwiftData

// MARK: - Period

enum WorkoutHistoryPeriod: Hashable, CaseIterable {
    case twoWeeks
    case month
    case threeMonths
    case sixMonths
    case year

    var displayName: String {
        switch self {
        case .twoWeeks: return "За 2 недели"
        case .month: return "За месяц"
        case .threeMonths: return "За 3 месяца"
        case .sixMonths: return "За полгода"
        case .year: return "За год"
        }
    }

    var days: Int {
        switch self {
        case .twoWeeks: return 14
        case .month: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .year: return 365
        }
    }
}

// MARK: - UI transport models

struct WorkoutHistorySet: Hashable {
    let weight: Double
    let reps: Int
}

struct WorkoutHistoryItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let subtitle: String
    let dateLabel: String
    let sets: [WorkoutHistorySet]
}

// MARK: - View

struct WorkoutHistoryView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \WorkoutLocal.startedAt, order: .reverse)
    private var workouts: [WorkoutLocal]

    @State private var selectedPeriod: WorkoutHistoryPeriod = .twoWeeks
    @State private var selectedItem: WorkoutHistoryItem?

    private var filteredWorkouts: [WorkoutLocal] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -selectedPeriod.days, to: .now) ?? .distantPast
        return workouts.filter { workout in
            guard let endedAt = workout.endedAt else { return false }
            return endedAt >= cutoff
        }
    }

    private var historyItems: [WorkoutHistoryItem] {
        filteredWorkouts.flatMap { workout -> [WorkoutHistoryItem] in
            let referenceDate = workout.endedAt ?? workout.startedAt
            let label = Self.formatDate(referenceDate)
            return workout.exercises
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { ex in
                    WorkoutHistoryItem(
                        id: ex.id,
                        name: ex.exerciseName,
                        subtitle: ex.exerciseSubtitle,
                        dateLabel: label,
                        sets: ex.sets
                            .sorted { $0.createdAt < $1.createdAt }
                            .map { WorkoutHistorySet(weight: $0.weight, reps: $0.reps) }
                    )
                }
        }
    }

    private var groupedItems: [(label: String, items: [WorkoutHistoryItem])] {
        var seenLabels: [String] = []
        var groups: [String: [WorkoutHistoryItem]] = [:]
        for item in historyItems {
            if groups[item.dateLabel] == nil {
                seenLabels.append(item.dateLabel)
                groups[item.dateLabel] = []
            }
            groups[item.dateLabel]?.append(item)
        }
        return seenLabels.map { (label: $0, items: groups[$0] ?? []) }
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            if historyItems.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedItem) { item in
            WorkoutHistoryDetailView(item: item)
                .presentationDetents([.height(sheetHeight(for: item))])
                .presentationDragIndicator(.visible)
        }
    }

    private func sheetHeight(for item: WorkoutHistoryItem) -> CGFloat {
        let headerHeight: CGFloat = 110
        let cellHeight: CGFloat = 44
        let trailing: CGFloat = 32
        return headerHeight + CGFloat(item.sets.count) * cellHeight + trailing
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

                    Text("История тренировок")
                        .headline24Semibold()
                }
                .padding(.horizontal, 16)

                AppChipGroup(
                    items: WorkoutHistoryPeriod.allCases,
                    selected: $selectedPeriod,
                    titleFor: { $0.displayName }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)

            Divider()
        }
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(groupedItems, id: \.label) { group in
                    section(label: group.label, items: group.items)
                }
            }
            .padding(.bottom, 16)
        }
    }

    private func section(label: String, items: [WorkoutHistoryItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .body17Semibold()
                .foregroundStyle(Color.appBlack)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                ForEach(items) { item in
                    AppCell(
                        title: item.name,
                        subtitle: item.subtitle
                    ) {
                        selectedItem = item
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("Нет данных")
                .body15Regular()
                .foregroundStyle(Color.appGray)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        let raw = formatter.string(from: date)
        return raw.prefix(1).uppercased() + raw.dropFirst()
    }
}

// MARK: - Previews

#Preview {
    WorkoutHistoryView()
}
