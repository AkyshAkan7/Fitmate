//
//  WeekDayView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

enum DayStatus {
    case none
    case green
    case yellow
    case red

    var imageName: String? {
        switch self {
        case .none: return nil
        case .green: return "greenDot"
        case .yellow: return "yellowDot"
        case .red: return "redDot"
        }
    }
}

struct WeekDayView: View {
    private let calendar = Calendar.current
    private let weekDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    // Status for each day (Monday to Sunday)
    var dayStatuses: [DayStatus] = []

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(0..<7), id: \.self) { index in
                let date = dateForIndex(index)
                let isToday = calendar.isDateInToday(date)
                let status = statusForDay(index: index, isToday: isToday)

                VStack(spacing: 2) {
                    Text(weekDays[index])
                        .body13Medium()
                        .foregroundColor(.appGray)

                    if let imageName = status.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    } else {
                        Color.clear
                            .frame(width: 20, height: 20)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func statusForDay(index: Int, isToday: Bool) -> DayStatus {
        // If status is provided for this day, use it
        if index < dayStatuses.count {
            return dayStatuses[index]
        }
        
        return isToday ? .yellow : .none
    }

    private func dateForIndex(_ index: Int) -> Date {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // Convert to Monday = 0
        let mondayOffset = (weekday + 5) % 7
        let startOfWeek = calendar.date(byAdding: .day, value: -mondayOffset, to: today)!
        return calendar.date(byAdding: .day, value: index, to: startOfWeek)!
    }
}

#Preview {
    VStack(spacing: 20) {
        WeekDayView()

        WeekDayView(dayStatuses: [.green, .red, .yellow, .none, .none, .none, .none])
    }
    .padding(.horizontal, 16)
}
