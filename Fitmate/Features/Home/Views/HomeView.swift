//
//  HomeView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @AppStorage(StorageKeys.isAIBannerHidden) private var isAIBannerHidden = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    // Navigation Bar
                    HStack {
                        Image("logoText")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)

                        Spacer()

                        NavigationLink {
                            ProfileView()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Профиль")
                                    .body17Regular()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.appGray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)

                    Divider()
                }

                ScrollView {
                    VStack(spacing: 0) {
                        WeekDayView()
                            .padding(.top, 16)

                        VStack(spacing: 0) {
                            StatsCardView(
                                title: "Прогресс силовых",
                                subtitle: "Упражнений: 12"
                            ) {
                                print("tap")
                            }

                            Divider()
                                .padding(.leading, 16)

                            StatsCardView(
                                title: "История тренировок",
                                subtitle: "Завершено тренировок: 56"
                            ) {
                                print("tap")
                            }
                        }
                        .cornerRadius(16)
                        .padding(.top, 20)

                        if !isAIBannerHidden {
                            HomeBannerView {
                                withAnimation {
                                    isAIBannerHidden = true
                                }
                            }
                            .padding(.top, 16)
                        }
                        
                        WorkoutTemplatesSection {
                            // TODO: Navigate to create template
                        }
                        .padding(.top, 24)
                        
                        AppButton(title: "Быстрый старт", type: .secondary) {
                            print("tapped")
                        }
                        .padding(.top, 24)
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(Color.clear)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
