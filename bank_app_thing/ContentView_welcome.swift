//
//  ContentViewWelcome.swift
//  bank_app_thing
//
//  Created by lewis mills on 27/01/2025.
//  Refactored for style and clarity
//

import SwiftUI

struct ContentView_welcome: View {
    @StateObject private var auth = AuthManager()
    // State variables kept for future extensibility
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var address: String = ""
    @State private var mobileNumber: String = ""
    
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Replace with your actual server URL
    private let serverURL = "http://localhost:3031/UserDetails"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.color1)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 36) {
                        Spacer().frame(height: 24)
                        Image("Image")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                            .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 4)
                            .padding(.bottom, 10)
                        
                        Text("Welcome to This Bank Thing 🎉")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.color0)
                            .padding(.top, 14)
                        
                        Text("Open a personal bank account in less than 10 minutes.")
                            .font(.title3)
                            .foregroundColor(.color0.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 18) {
                            NavigationLink(destination: ContentView_join0(auth: auth)) {
                                Text("Join")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.color2)
                                    .cornerRadius(14)
                                    .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.top, 20)
                            .disabled(isLoading)
                            
                            NavigationLink(destination: LoginView(auth: auth)) {
                                Text("Login")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.color2)
                                    .cornerRadius(14)
                                    .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 2)
                            }
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
                            .disabled(isLoading)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 30)
                }
            }
        }
    }
}

struct ContentViewWelcome_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_welcome()
    }
}
