//
//  contentView1.swift
//  War Card Game
//
//  Created by lewis mills on 25/03/2025.
//



import SwiftUI

struct contentView_login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var FirstName: String = ""
    @State private var LastName: String = ""
    @State private var Address: String = ""
    @State private var MobileNumber: String = ""
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.color1)
                    .ignoresSafeArea()
                VStack {
                    // Login Header
                    Text("Welcome back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 250)
                        .padding(.bottom, 40)
                    // Email Field
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .onSubmit {
                            print("Email submitted: \(email)")
                        }
        
                        .padding(.bottom, 40)
                    
                    Button(action: {
                        print("Login button pressed")
                        print("Attempting login with:")
                        print("Email: \(email)")
                    }) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal )
                      
                    }
                   
                    Spacer()
                    
                }
            }
        }
    }
}

struct ContentView_login_Previews: PreviewProvider {
    static var previews: some View {
        contentView_login()
    }
}
