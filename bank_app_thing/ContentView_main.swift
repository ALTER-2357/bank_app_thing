//
//  ContentView 2.swift
//  bank_app_thing
//
//  Created by lewis mills on 26/03/2025.
//


//
//  ContentView 2.swift
//  bank_app_thing
//
//  Created by lewis mills on 26/03/2025.
//


//
//  ContentView.swift
//  bank_app_thing
//
//  Created by lewis mills on 27/01/2025.
//


import SwiftUI
import SwiftData
import CryptoKit

struct ContentView_main: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            ContentViewHomepage()
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            contentView_join()
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "banknote")
                    Text("pots")
                }

            UserDetailsView()
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
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


