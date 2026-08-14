//
//  WorkoutHistoryDetailView.swift
//  Fitmate
//
//  Created by Akan Akysh on 13/05/26.
//

import SwiftUI

struct WorkoutHistoryDetailView: View {
    let item: WorkoutHistoryItem

    @State private var contentHeight: CGFloat = 200

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)

            Divider()

            VStack(spacing: 0) {
                ForEach(Array(item.sets.enumerated()), id: \.offset) { index, set in
                    HStack {
                        Text("\(index + 1) подход")
                            .body15Regular()
                            .foregroundStyle(Color.appBlack)

                        Spacer()

                        Text("\(set.weight.formatted) кг x \(set.reps)")
                            .body15Regular()
                            .foregroundStyle(Color.appBlack)
                    }
                    .padding(16)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onGeometryChange(for: CGFloat.self, of: { $0.size.height }) { contentHeight = $0 }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.white)
        .presentationBackground(.white)
        .presentationDetents([.height(contentHeight)])
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .headline24Bold()
                .foregroundStyle(Color.appBlack)

            if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .body15Regular()
                    .foregroundStyle(Color.appGray)
            }
        }
    }
}

#Preview {
    Color.lightGray
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            WorkoutHistoryDetailView(
                item: WorkoutHistoryItem(
                    id: UUID(),
                    name: "Жим штангой",
                    subtitle: "В наклоне",
                    imageURL: nil,
                    dateLabel: "Понедельник, 6 апреля",
                    sets: [
                        WorkoutHistorySet(weight: 30, reps: 10),
                        WorkoutHistorySet(weight: 50, reps: 10),
                        WorkoutHistorySet(weight: 40, reps: 8)
                    ]
                )
            )
            .presentationDragIndicator(.visible)
        }
}
