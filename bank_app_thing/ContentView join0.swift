//
//  ContentView 2.swift
//  bank_app_thing
//
//  Created by lewis mills on 08/04/2025.
//


//
//  contentView1.swift
//  War Card Game
//
//  Created by lewis mills on 25/03/2025.
//

import SwiftUI

struct ContentView_join0: View {
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
                    VStack(spacing: 20) {
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Text("lets start with your name.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.color0)
                            .padding(.top, 40)
                        
                        // Form Fields
                        VStack(spacing: 15) {
                            // First Name
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                            
                            // Last Name
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)

                        }
                        .padding(.horizontal)
                     
                        NavigationLink(destination: ContentView_join1(firstName: $firstName, lastName: $lastName)
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
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }


