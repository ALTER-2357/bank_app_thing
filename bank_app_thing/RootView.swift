//
//  RootView.swift
//  bank_app_thing
//
//  Created by lewis mills on 17/06/2025.
//
    
    
import SwiftUI
import SwiftData

struct RootView: View {
    @StateObject var auth = AuthManager()
    @State private var showOverdraft = false

    var body: some View {
        Group {

                TabView {
                    // Home Tab
                    ContentViewHomepage(auth: auth)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    // Transactions Tab
                    Contentview_transfers()
                        .tabItem {
                            Image(systemName: "person.line.dotted.person.fill")
                            Text("transfers")
                        }
                      
                    
                    // pots Tab ContentView_transfers
                 
                    Contentview_pots()
                        .tabItem {
                            Image("custom.pot")
                            Text("pots")
                        }
                    
                
                    ContentView_help()
                        .tabItem {
                            Image(systemName: "questionmark.circle")
                            Text("Help")
                        }
                }
                .navigationBarBackButtonHidden(true)
   
                
            }
        }
    }

