//
//  WorkoutCompleteView.swift
//  Fitmate
//
//  Created by Akan Akysh on 02/03/26.
//

import SwiftUI

struct WorkoutCompleteView: View {
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack(spacing: 0) {
            Image("workoutComplete")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 440, alignment: .top)
                .clipped()
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [.white.opacity(0), .white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 160)
                }

            Image("darkDot")
                .padding(.top, 24)

            Text("Тренировка окончена")
                .headline24Bold()
                .foregroundStyle(Color.appBlack)
                .padding(.top, 16)

            Text("Каждая тренировка — шаг к сильному и выносливому себе. Не сдавайся!")
                .body17Regular()
                .foregroundStyle(Color.appGray)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 32)

            AppButton(title: "На главную") {
                router.popToRoot()
            }
            .padding(.top, 64)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    WorkoutCompleteView()
        .environmentObject(Router())
}
