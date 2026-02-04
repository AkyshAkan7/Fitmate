//
//  HomeView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with blur
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

                    // Divider between nav bar and week selector
                    Divider()
                }

                ScrollView {
                    VStack(spacing: 0) {
                        // Week Day Selector
                        WeekDayView()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
