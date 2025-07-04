//
//  ContentView 2.swift
//  bank_app_thing
//
//  Created by lewis mills on 08/04/2025.
//


//
//  ConContentView_join1swift
//  bank_app_thing
//
//  Created by lewis mills on 08/04/2025.
//


import SwiftUI

struct ContentView_join1: View {
    @Binding var firstName: String // Use @Binding
    @Binding var lastName: String // Use @Binding
    
    @State var Email: String = ""
    @State var Address: String = ""
    @State var mobileNumber: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.color1)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Text("now enter your email and your address.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.color0)
                            .padding(.top, 40)
                        
                        // Form Fields
                        VStack(spacing: 15) {
                            // First Name
                            TextField("Email", text: $Email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                            
                            
                            
                            // Last Name
                            TextField("Address", text: $Address)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                            
                            NavigationLink(destination: ContentView_join2(firstName: $firstName, lastName: $lastName, email: $Email , address: $Address)
                                .environmentObject(AuthManager.shared)
                                  ) {
                                      Text("Next")
                                  }
                                  .font(.headline)
                                  .foregroundColor(.white)
                                  .frame(maxWidth: .infinity)
                                  .frame(height: 50)
                                  .background(Color.color2)
                                  .cornerRadius(10)
                                  .padding(.horizontal)
                                  .padding(.top, 20)
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}
