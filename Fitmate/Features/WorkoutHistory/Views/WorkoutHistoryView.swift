//
//  WorkoutHistoryView.swift
//  Fitmate
//
//  Created by Akan Akysh on 12/05/26.
//

import SwiftUI

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
}

// MARK: - Item

struct WorkoutHistorySet: Hashable {
    let weight: Int
    let reps: Int
}

struct WorkoutHistoryItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let dateLabel: String
    var sets: [WorkoutHistorySet] = [
        .init(weight: 30, reps: 10),
        .init(weight: 50, reps: 10),
        .init(weight: 30, reps: 10),
        .init(weight: 50, reps: 10),
        .init(weight: 40, reps: 10)
    ]
}

// MARK: - View

struct WorkoutHistoryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPeriod: WorkoutHistoryPeriod = .twoWeeks
    @State private var selectedItem: WorkoutHistoryItem?
    @State var items: [WorkoutHistoryItem] = [
        .init(name: "Жим штангой", subtitle: "В наклоне", dateLabel: "Понедельник, 6 апреля"),
        .init(name: "Жим гантелями", subtitle: "В наклоне", dateLabel: "Понедельник, 6 апреля"),
        .init(name: "Жим штангой", subtitle: "В наклоне", dateLabel: "Понедельник, 6 апреля"),
        .init(name: "Жим гантелями", subtitle: "В наклоне", dateLabel: "Понедельник, 6 апреля"),
        .init(name: "Тяга штангой", subtitle: "В наклоне", dateLabel: "Пятница, 3 апреля"),
        .init(name: "Тяга гантелями", subtitle: "В наклоне", dateLabel: "Пятница, 3 апреля"),
        .init(name: "Тяга гантелями", subtitle: "В наклоне", dateLabel: "Пятница, 3 апреля"),
        .init(name: "Тяга гантелями", subtitle: "В наклоне", dateLabel: "Пятница, 3 апреля")
    ]

    private var groupedItems: [(label: String, items: [WorkoutHistoryItem])] {
        let groups = Dictionary(grouping: items, by: \.dateLabel)
        return groups
            .map { (label: $0.key, items: $0.value) }
            .sorted { $0.label < $1.label }
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            if items.isEmpty {
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
        // header + divider + cells + bottom padding
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
}

// MARK: - Previews

#Preview("Empty") {
    WorkoutHistoryView()
}

#Preview("Filled") {
    WorkoutHistoryView(items: [
        .init(name: "Жим штангой", subtitle: "В наклоне", dateLabel: "Понедельник, 6 апреля"),
        .init(name: "Жим гантелями", subtitle: "В наклоне", dateLabel: "Понедельник, 6 апреля"),
        .init(name: "Жим штангой", subtitle: "В наклоне", dateLabel: "Понедельник, 6 апреля"),
        .init(name: "Жим гантелями", subtitle: "В наклоне", dateLabel: "Понедельник, 6 апреля"),
        .init(name: "Тяга штангой", subtitle: "В наклоне", dateLabel: "Пятница, 3 апреля"),
        .init(name: "Тяга гантелями", subtitle: "В наклоне", dateLabel: "Пятница, 3 апреля"),
        .init(name: "Тяга гантелями", subtitle: "В наклоне", dateLabel: "Пятница, 3 апреля"),
        .init(name: "Тяга гантелями", subtitle: "В наклоне", dateLabel: "Пятница, 3 апреля")
    ])
}
