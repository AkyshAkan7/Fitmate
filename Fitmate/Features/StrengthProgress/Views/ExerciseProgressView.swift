//
//  ExerciseProgressView.swift
//  Fitmate
//
//  Created by Akan Akysh on 30/04/26.
//

import SwiftUI
import Charts

struct ExerciseProgressView: View {
    @Environment(\.dismiss) private var dismiss

    let exerciseName: String
    let exerciseSubtitle: String

    @State private var selectedRange: TimeRange = .month1
    @Namespace private var rangeAnimation

    // MARK: - Mock Data

    private let latestWeight: Int = 76
    private let latestReps: Int = 10
    private let latestDate: Date = makeDate(2025, 8, 2)

    private let dataPoints: [WeightPoint] = [
        WeightPoint(date: makeDate(2025, 7, 5), weight: 70),
        WeightPoint(date: makeDate(2025, 7, 9), weight: 73),
        WeightPoint(date: makeDate(2025, 7, 13), weight: 72.5),
        WeightPoint(date: makeDate(2025, 7, 17), weight: 73),
        WeightPoint(date: makeDate(2025, 7, 21), weight: 74),
        WeightPoint(date: makeDate(2025, 7, 25), weight: 75),
        WeightPoint(date: makeDate(2025, 7, 29), weight: 74.5),
        WeightPoint(date: makeDate(2025, 8, 2), weight: 76),
    ]

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

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

    private var latestResultBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(latestWeight) кг")
                    .h1Bold()
                    .foregroundStyle(Color.appBlack)
                Text("x \(latestReps)")
                    .h1Bold()
                    .foregroundStyle(Color.appGray.opacity(0.5))
            }

            Text(latestDate.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "ru_RU"))))
                .body15Regular()
                .foregroundStyle(Color.appGray)
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
        Chart {
            ForEach(dataPoints) { point in
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

            ForEach(dataPoints) { point in
                LineMark(
                    x: .value("Дата", point.date),
                    y: .value("Вес", point.weight)
                )
                .foregroundStyle(Color.green)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.linear)
            }

            if let last = dataPoints.last {
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
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appGray.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Models

private struct WeightPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

private enum TimeRange: String, CaseIterable, Identifiable {
    case month1
    case month3
    case month6

    var id: String { rawValue }

    var title: String {
        switch self {
        case .month1: "1 мес"
        case .month3: "3 мес"
        case .month6: "6 мес"
        }
    }
}

// MARK: - Helpers

private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

#Preview {
    ExerciseProgressView(
        exerciseName: "Жим штангой",
        exerciseSubtitle: "В наклоне на хуй"
    )
}
