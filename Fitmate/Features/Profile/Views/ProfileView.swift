//
//  ProfileView.swift
//  Fitmate
//
//  Created by Akan Akysh on 04/02/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Профиль")
                .headline24Bold()

            Spacer()

            Button("Выйти из аккаунта") {
                authManager.signOut()
            }
            .foregroundColor(.red)
            .body17Regular()
        }
        .padding()
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                        Text("Назад")
                            .body15Regular()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthManager())
    }
}
