//
//  SettingsView.swift
//  bank_app_thing
//
//  Created by lewis mills on 20/06/2025.
//


import SwiftUI

struct SettingsView: View {
    @ObservedObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ZStack {
                    Spacer()
                    Text("SettingsView")
                        .font(.title)
                }
              
                Button(role: .destructive) {
                    authManager.logout()

                    
                } label: {
                    Text("Log Out")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                Spacer()
            }
        }
    }
}
