//
//  ProfileView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.primary)
                }

                Text("Профиль")
                    .headline24Semibold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        SubscriptionCardView(
                            planName: "3 месяца",
                            nextBillingDate: "24.12.2026"
                        )

                        // Language selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Язык интерфейса")
                                .body17Semibold()

                            AppChipGroup(
                                items: AppLanguage.allCases,
                                selected: Binding(
                                    get: { languageManager.currentLanguage },
                                    set: { languageManager.setLanguage($0) }
                                ),
                                titleFor: { $0.displayName }
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        VStack(spacing: 8) {
                            AppButton(title: "Выйти из аккаунта", type: .secondary) {
                                authManager.signOut()
                            }

                            AppButton(title: "Удалить аккаунт", type: .destructive) {
                                // TODO: Delete account
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthManager())
            .environmentObject(LanguageManager())
    }
}
