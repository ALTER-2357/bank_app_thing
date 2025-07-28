//
//  ContentViewJoin0.swift
//  bank_app_thing
//
//  Created by lewis mills on 08/04/2025.
//  Refactored & styled by Copilot
//

import SwiftUI

struct ContentView_join0: View {
    @ObservedObject var auth: AuthManager
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var address: String = ""
    @State private var mobileNumber: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.color1)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 36) {
                        Spacer().frame(height: 48)
                        header
                        formFields
                        nextButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text("Let's Start With Your Name")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.color0)
            Text("Please enter your first and last name to continue.")
                .font(.title3)
                .foregroundColor(.color0.opacity(0.7))
        }
        .multilineTextAlignment(.center)
        .padding(.bottom, 12)
    }

    private var formFields: some View {
        VStack(spacing: 18) {
            // First Name
            TextField("First Name", text: $firstName)
                .textFieldStyle(StyledTextField())
            // Last Name
            TextField("Last Name", text: $lastName)
                .textFieldStyle(StyledTextField())
        }
        .padding(.top, 10)
    }

    private var nextButton: some View {
        NavigationLink(
            destination: ContentView_join1(auth: auth, firstName: $firstName, lastName: $lastName)
        ) {
            Text("Next")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .background(Color.color2)
        .cornerRadius(12)
        .padding(.top, 28)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 3)
        .padding(.bottom, 12)
    }
}

// MARK: - Custom TextField Style

struct StyledTextField: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.color2, lineWidth: 1)
            )
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .autocapitalization(.words)
            .disableAutocorrection(true)
    }
}
