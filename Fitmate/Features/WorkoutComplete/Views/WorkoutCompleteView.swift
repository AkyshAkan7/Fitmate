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
            Spacer()

            Image("workoutComplete")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text("Тренировка окончена")
                .headline24Bold()
                .foregroundStyle(Color.appBlack)
                .padding(.top, 24)

            Text("Каждая тренировка — шаг к сильному и выносливому себе. Не сдавайся!")
                .body17Regular()
                .foregroundStyle(Color.appGray)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 32)

            Spacer()

            AppButton(title: "На главную") {
                router.popToRoot()
            }
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
