//
//  WorkoutTemplatesSection.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

struct WorkoutTemplate: Identifiable {
    let id = UUID()
    let name: String
    let exerciseCount: Int
}

struct WorkoutTemplatesSection: View {
    var templates: [WorkoutTemplate] = []
    var onCreateTap: (() -> Void)? = nil
    var onTemplateTap: ((WorkoutTemplate) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Шаблоны тренировок")
                    .body17Semibold()

                Spacer()

                Button {
                    onCreateTap?()
                } label: {
                    Text("Создать")
                        .body15Semibold()
                        .foregroundStyle(.blue)
                }
            }

            if templates.isEmpty {
                // Empty placeholder
                Text("Тут будут шаблоны")
                    .body15Regular()
                    .foregroundStyle(Color.appGray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundStyle(Color.appGray.opacity(0.5))
                    )
            } else {
                // Templates list
                VStack(spacing: 0) {
                    ForEach(Array(templates.enumerated()), id: \.element.id) { index, template in
                        Button {
                            onTemplateTap?(template)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .body15Regular()
                                        .foregroundStyle(Color.primary)
                                    
                                    Text("Упражнений: \(template.exerciseCount)")
                                        .body13Regular()
                                        .foregroundStyle(Color.appGray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.appGray)
                            }
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if index < templates.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .cornerRadius(16)
            }
        }
    }
}

#Preview("With Templates") {
    VStack(spacing: 32) {
        WorkoutTemplatesSection()
            .padding(.horizontal, 16)
        
        WorkoutTemplatesSection(
            templates: [
                WorkoutTemplate(name: "Грудь и бицепс", exerciseCount: 5),
                WorkoutTemplate(name: "Спина и трицепс", exerciseCount: 4)
            ]
        )
        .padding(.horizontal, 16)
    }
}
