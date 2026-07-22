//
//  ExerciseProgressView.swift
//  Fitmate
//
//  Created by Akan Akysh on 30/04/26.
//

import SwiftUI
import SwiftData
import Charts

struct ExerciseProgressView: View {
    @Environment(\.dismiss) private var dismiss

    let exerciseName: String
    let exerciseSubtitle: String
    let exerciseId: String

    @Query private var workouts: [WorkoutLocal]

    @State private var selectedRange: TimeRange = .month1
    @Namespace private var rangeAnimation

    // MARK: - Data

    /// Кастомные упражнения не имеют `exerciseId` — их матчим по имени снапшота.
    private func matches(_ exercise: WorkoutExerciseLocal) -> Bool {
        exerciseId.isEmpty
            ? exercise.exerciseId.isEmpty && exercise.exerciseName == exerciseName
            : exercise.exerciseId == exerciseId
    }

    private func bestSet(in workout: WorkoutLocal) -> WorkoutSetLocal? {
        let sets = workout.exercises
            .filter(matches)
            .flatMap { $0.sets }
        return sets.max { lhs, rhs in
            lhs.weight != rhs.weight ? lhs.weight < rhs.weight : lhs.reps < rhs.reps
        }
    }

    /// Лучший подход (макс. вес) каждой завершённой тренировки с этим упражнением.
    private var allPoints: [WeightPoint] {
        var result: [WeightPoint] = []
        for workout in workouts where workout.endedAt != nil {
            guard let best = bestSet(in: workout) else { continue }
            result.append(
                WeightPoint(
                    date: workout.endedAt ?? workout.startedAt,
                    weight: best.weight,
                    reps: best.reps
                )
            )
        }
        return result.sorted { $0.date < $1.date }
    }

    private var points: [WeightPoint] {
        guard let cutoff = Calendar.current.date(byAdding: .month, value: -selectedRange.months, to: Date()) else {
            return allPoints
        }
        return allPoints.filter { $0.date >= cutoff }
    }

    private var latest: WeightPoint? { allPoints.last }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            if allPoints.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        latestResultBlock

                        rangePicker

                        chartCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
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

                VStack(alignment: .leading, spacing: 4) {
                    Text(exerciseName)
                        .headline24Semibold()
                    Text(exerciseSubtitle)
                        .body15Regular()
                        .foregroundStyle(Color.appGray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }

    // MARK: - Latest Result

    @ViewBuilder
    private var latestResultBlock: some View {
        if let latest {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(latest.weight)) кг")
                        .h1Bold()
                        .foregroundStyle(Color.appBlack)
                    Text("x \(latest.reps)")
                        .h1Bold()
                        .foregroundStyle(Color.appGray.opacity(0.5))
                }

                Text(latest.date.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "ru_RU"))))
                    .body15Regular()
                    .foregroundStyle(Color.appGray)
            }
        }
    }

    // MARK: - Range Picker

    private var rangePicker: some View {
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases) { range in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedRange = range
                    }
                } label: {
                    Text(range.title)
                        .body13Medium()
                        .foregroundStyle(selectedRange == range ? Color.appBlack : Color.appGray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            if selectedRange == range {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .matchedGeometryEffect(id: "rangeSelector", in: rangeAnimation)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sensoryFeedback(.impact(weight: .light), trigger: selectedRange)
    }

    // MARK: - Chart

    private var chartCard: some View {
        Group {
            if points.isEmpty {
                Text("Нет данных за выбранный период")
                    .body15Regular()
                    .foregroundStyle(Color.appGray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
            } else {
                chart
            }
        }
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appGray.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var chart: some View {
        Chart {
            ForEach(points) { point in
                AreaMark(
                    x: .value("Дата", point.date),
                    y: .value("Вес", point.weight)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.green.opacity(0.3), Color.green.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.linear)
            }

            ForEach(points) { point in
                LineMark(
                    x: .value("Дата", point.date),
                    y: .value("Вес", point.weight)
                )
                .foregroundStyle(Color.green)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.linear)
            }

            if let last = points.last {
                RuleMark(x: .value("Последняя", last.date))
                    .foregroundStyle(Color.appGray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))

                PointMark(
                    x: .value("Дата", last.date),
                    y: .value("Вес", last.weight)
                )
                .foregroundStyle(Color.green)
                .symbolSize(80)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                    .foregroundStyle(Color.appGray.opacity(0.2))
                AxisValueLabel {
                    if let weight = value.as(Double.self) {
                        Text("\(Int(weight)) кг")
                            .body13Regular()
                            .foregroundStyle(Color.appGray)
                    }
                }
            }
        }
        .frame(height: 220)
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

// MARK: - Models

private struct WeightPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let reps: Int
}

private enum TimeRange: String, CaseIterable, Identifiable {
    case month1
    case month3
    case month6

    var id: String { rawValue }

    var months: Int {
        switch self {
        case .month1: 1
        case .month3: 3
        case .month6: 6
        }
    }

    var title: String {
        switch self {
        case .month1: "1 мес"
        case .month3: "3 мес"
        case .month6: "6 мес"
        }
    }
}

#Preview {
    ExerciseProgressView(
        exerciseName: "Жим штангой",
        exerciseSubtitle: "В наклоне",
        exerciseId: ""
    )
}
