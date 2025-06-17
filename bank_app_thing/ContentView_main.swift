/*
 //  ContentView 2.swift
 //  bank_app_thing
 //
 //  Created by lewis mills on 26/03/2025.
 //
 
 import SwiftUI
 import SwiftData
 import CryptoKit
 
 struct ContentView_main: View {
 // Access the stored users from SwiftData
 @Query private var storedUsers: [SwiftDataStore]
 @State private var needsLogin: Bool = false
 
 var body: some View {
 // Check if a user exists in the data store
 if let _ = storedUsers.first {
 // User exists, show main app
 
 ContentView_Transactions()
 .tabItem {
 Image(systemName: "banknote")
 Text("pots")
 }
 
 UserDetailsView()
 .tabItem {
 Image(systemName: "gearshape.fill")
 Text("help")
 }
 }
 }
 
 }
 
 
 struct HomeView: View {
 @Query private var storedUsers: [SwiftDataStore]
 
 var body: some View {
 VStack {
 Text("Home View")
 .font(.largeTitle)
 .padding()
 }
 }
 }
 
 struct SettingsView: View {
 var body: some View {
 VStack {
 Text("Settings View")
 .font(.largeTitle)
 .padding()
 }
 }
 }
 
 
 struct ContentView_main_Previews: PreviewProvider {
 static var previews: some View {
 ContentView_main()
 .modelContainer(SwiftDataContainer.shared.container)
 }
 }
 
 */
 
