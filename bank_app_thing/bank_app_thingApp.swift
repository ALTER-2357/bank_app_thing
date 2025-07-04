//
//  wip_bankApp.swift
//  wip-bank
//
//  Created by lewis mills on 15/04/2025.
//

import SwiftUI
import SwiftData

@main
struct bank_app_thingApp: App {
    @StateObject private var authManager = AuthManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                RootView(auth: authManager) // <-- Show homepage if authenticated
            } else {
                ContentView_welcome(authManager: authManager)  // <-- Show welcome if not authenticated
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
