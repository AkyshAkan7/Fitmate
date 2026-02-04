//
//  HomeBannerView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

struct HomeBannerView: View {
    var onClose: (() -> Void)? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("ИИ-помощник")
                    .body15Semibold()
                    .foregroundStyle(.primary)

                Text("Функция с персональными подсказками уже в разработке")
                    .body13Regular()
                    .foregroundStyle(Color.appGray)
                    .padding(.trailing, 100)
            }

            Spacer(minLength: 16)
        }
        .padding(16)
        .background(alignment: .trailing) {
            Image("lightningIllustration")
                .resizable()
                .scaledToFit()
                .frame(height: 240)
                .offset(x: 26)
        }
        .background(Color.yellow)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .topTrailing) {
            Button {
                onClose?()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.appGray)
            }
            .padding(16)
        }
    }
}

#Preview {
    HomeBannerView()
        .padding(.horizontal, 16)
}
