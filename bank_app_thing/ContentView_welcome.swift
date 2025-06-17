
//
//  ContentView_Signup.swift
//  bank_app_thing
//
//  Created by lewis mills on 27/01/2025.
//

import SwiftUI

struct ContentView_welcome: View {
    @State private var Email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var Address: String = ""
    @State private var mobileNumber: String = ""
    
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
                        Image("Image")
                        // need a better name??????
                        Text("welcome to this bank thing. 🎉 \nOpen a personal bank in less than 10 minutes.")
                            .multilineTextAlignment(.center)
                            .fontWeight(.bold)
                            .foregroundColor(.color0)
                            .padding(.top, 40)
                    }
                    .padding()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    NavigationLink {
                        ContentView_join0() // ContentView_join0()
                    } label: {
                        Text("join")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.color2)
                            .cornerRadius(10)
                            .disabled(isLoading)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        Spacer()
                    }

                    NavigationLink {
                        RootView()   // ContentViewHomepage()
                    } label: {
                        Text("login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.color2)
                            .cornerRadius(10)
                            .disabled(isLoading)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        Spacer()
                    }
                }
            }
        }
    }
}

    struct ContentView_welcome_Previews: PreviewProvider {
        static var previews: some View {
            ContentView_welcome()
        }
    }
    

