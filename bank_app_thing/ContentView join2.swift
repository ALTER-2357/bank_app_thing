//
//  ContentViewJoin2.swift
//  War Card Game
//
//  Created by lewis mills on 25/03/2025.
//  Refactored & styled by Copilot
//

import SwiftUI

struct ContentView_join2: View {
    @ObservedObject var auth: AuthManager
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var address: String
    @State private var mobileNumber: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var registrationSuccess = false
    @State private var navigateToHome = false

    // Replace with your actual server URL
    private let serverURL = "http://localhost:3031/UserDetails"

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.color1)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 40)
                        header
                        mobileNumberField
                        registerButton
                        NavigationLink(destination: RootView(), isActive: $navigateToHome) { EmptyView() }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
            }
        }
        .alert("Registration Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if registrationSuccess {
                    navigateToHome = true
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text("Final Step 🎉")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.color0)
            Text("Enter your mobile number below to complete registration.")
                .font(.title3)
                .foregroundColor(.color0.opacity(0.7))
        }
        .multilineTextAlignment(.center)
        .padding(.bottom, 20)
    }

    private var mobileNumberField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mobile Number")
                .font(.headline)
                .foregroundColor(.color0.opacity(0.8))
            TextField("Enter mobile number", text: $mobileNumber)
                .keyboardType(.numberPad)
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
        .padding(.top, 10)
    }

    private var registerButton: some View {
        Button(action: submitToServer) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
            }
        }
        .background(isLoading ? Color.color2.opacity(0.7) : Color.color2)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .cornerRadius(12)
        .disabled(isLoading)
        .padding(.top, 24)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 3)
    }

    private func submitToServer() {
        print("Form values before submission:")
        print("First Name: \(firstName)")
        print("Last Name: \(lastName)")
        print("Email: \(email)")
        print("Address: \(address)")
        print("Mobile Number: \(mobileNumber)")

        guard !email.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !address.isEmpty,
              !mobileNumber.isEmpty else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            registrationSuccess = false
            return
        }

        isLoading = true

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "FirstName", value: firstName),
            URLQueryItem(name: "LastName", value: lastName),
            URLQueryItem(name: "Email", value: email),
            URLQueryItem(name: "Address", value: address),
            URLQueryItem(name: "MobileNumber", value: mobileNumber)
        ]

        guard let url = URL(string: serverURL) else {
            alertMessage = "Invalid server URL."
            showAlert = true
            isLoading = false
            registrationSuccess = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        print("\nSending POST request to: \(url.absoluteString)")
        print("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Request body: \(components.percentEncodedQuery ?? "")\n")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                registrationSuccess = false

                if let error = error {
                    alertMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    alertMessage = "Invalid server response."
                    showAlert = true
                    return
                }

                print("Server response status code: \(httpResponse.statusCode)")

                if let data = data {
                    let responseString = String(data: data, encoding: .utf8) ?? "No readable data"
                    print("Server response body: \(responseString)")

                    if responseString.contains("invalid character") {
                        alertMessage = "Server couldn't understand our data format."
                    }
                }

                switch httpResponse.statusCode {
                case 200..<300:
                    alertMessage = "Registration successful!"
                    registrationSuccess = true
                    
                    // Store the PAN using AuthManager only on successful registration
                    if let data = data {
                        let responseString = String(data: data, encoding: .utf8) ?? "No readable data"
                        let pan = responseString.trimmingCharacters(in: .whitespacesAndNewlines)
                        auth.setPan(pan)
                        print("PAN stored in AuthManager: \(pan)")
                    }
                case 400:
                    alertMessage = "Bad request (400) - please check your data."
                default:
                    alertMessage = "Server returned status code \(httpResponse.statusCode)."
                }

                showAlert = true
            }
        }
        task.resume()
    }
}
/// after the account is made and got a pan back this code will store it and  move on to the homepage to get all the info




