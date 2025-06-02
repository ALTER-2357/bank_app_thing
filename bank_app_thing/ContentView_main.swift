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

struct ContentView_trends: View {
    var body: some View {
        TabView {
            Contentview_homepage()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            Contentview_pots()
                .tabItem {
                    Image(systemName: "banknote")
                    Text("pots")
                }

            ContentView_help()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("help")
                }
        }
    }
}

struct HomeView: View {
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


struct ContentView_trends_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_trends()
    }
}
