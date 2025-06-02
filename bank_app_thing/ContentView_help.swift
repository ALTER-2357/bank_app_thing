//
//  ContentView 3.swift
//  bank_app_thing
//
//  Created by lewis mills on 26/03/2025.
//


import SwiftUI

struct ContentView_help: View {
    var body: some View {
        NavigationStack {
            ZStack {
                
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                   
                        Text("help page")
                            .padding(20)
                            .font(.title)
                    }
                }
            }
        }
    }
}
    
    struct ContentView_help_Previews: PreviewProvider {
        static var previews: some View {
            ContentView_help()
        }
    }

