//
// ContentView join1.swift
//  War Card Game
//
//  Created by lewis mills on 25/03/2025.
//

import SwiftUI

struct ContentView_join2: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var address: String
    @State var mobileNumber: String = ""

    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // Replace with your actual server URL
    let serverURL = "http://localhost:3031/UserDetails"

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.color1)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Text("final step. 🎉 \nenter your mobile number.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.color0)
                            .padding(.top, 40)

                        VStack(spacing: 15) {
                            TextField("MobileNumber", text: $mobileNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        .padding(.horizontal)

                        Button(action: submitToServer) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Register")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        .background(Color.color2)
                        .cornerRadius(10)
                        .disabled(isLoading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .alert("Registration Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func submitToServer() {
        // 1. Verify all fields contain values
        print("Form values before submission:")
        print("First Name: \(firstName)")
        print("Last Name: \(lastName)")
        print("Email: \(email)")
        print("Address: \(address)")
        print("Mobile Number: \(mobileNumber)")

        // 2. Validate inputs
        guard !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !address.isEmpty, !mobileNumber.isEmpty else {
            alertMessage = "Please fill in all required fields"
            showAlert = true
            return
        }

        isLoading = true

        // 3. Create URLComponents to properly encode parameters
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "FirstName", value: firstName),
            URLQueryItem(name: "LastName", value: lastName),
            URLQueryItem(name: "Email", value: email),
            URLQueryItem(name: "Address", value: address),
            URLQueryItem(name: "MobileNumber", value: mobileNumber)
        ]

        guard let url = URL(string: serverURL) else {
            alertMessage = "Invalid server URL"
            showAlert = true
            isLoading = false
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

                if let error = error {
                    alertMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    alertMessage = "Invalid server response"
                    showAlert = true
                    return
                }

                print("Server response status code: \(httpResponse.statusCode)")

                if let data = data {
                    let responseString = String(data: data, encoding: .utf8) ?? "No readable data"
                    print("Server response body: \(responseString)")
                    
                    // Use AuthManager to handle login instead of directly setting UserDefaults
                    authManager.login(pan: responseString)
                    print("User logged in with PAN:", responseString)

                    if responseString.contains("invalid character") {
                        alertMessage = "Server couldn't understand our data format"
                    }
                }

                switch httpResponse.statusCode {
                case 200..<300:
                    alertMessage = "Registration successful!"
                case 400:
                    alertMessage = "Bad request (400) - please check your data"
                default:
                    alertMessage = "Server returned status code \(httpResponse.statusCode)"
                }

                showAlert = true
            }
        }
        task.resume()
    }
}


/// after the account is made and got a pan back this code will store it and  move on to the homepage to get all the info
