//
//  SubscriptionCardView.swift
//  Fitmate
//
//  Created by Akan Akysh on 05/02/26.
//

import SwiftUI

struct SubscriptionCardView: View {
    let planName: String
    let nextBillingDate: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Моя подписка")
                .body13Regular()
                .foregroundStyle(Color.appGray)

            Text(planName)
                .headline24Bold()
                .foregroundStyle(Color.primary)

            Text("Следующее списание \(nextBillingDate)")
                .body13Regular()
                .foregroundStyle(Color.appGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.yellow)
        .cornerRadius(16)
    }
}

#Preview {
    SubscriptionCardView(planName: "3 месяца", nextBillingDate: "24.12.2026")
        .padding(.horizontal, 16)
}
