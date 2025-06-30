
//
//  ContentViewJoin1.swift
//  bank_app_thing
//
//  Created by lewis mills on 08/04/2025.
//  Refactored & styled by Copilot
//

import SwiftUI

struct ContentView_join1: View {
    @Binding var firstName: String
    @Binding var lastName: String
    
    @State private var email: String = ""
    @State private var address: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.color1)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 36) {
                        Spacer().frame(height: 32)
                        header
                        formFields
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Text("Almost There!")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.color0)
            Text("Now enter your email and address.")
                .font(.title3)
                .foregroundColor(.color0.opacity(0.7))
        }
        .multilineTextAlignment(.center)
        .padding(.bottom, 20)
    }
    
    private var formFields: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(.color0.opacity(0.8))
                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
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
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Address")
                    .font(.headline)
                    .foregroundColor(.color0.opacity(0.8))
                TextField("Enter your address", text: $address)
                    .autocapitalization(.words)
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
            }
            
            NavigationLink(
                destination: ContentView_join2(
                    firstName: $firstName,
                    lastName: $lastName,
                    email: $email,
                    address: $address
                )
            ) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.color2)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 3)
            }
            .padding(.top, 8)
        }
        .padding(.top, 10)
    }
}
