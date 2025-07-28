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
            if let pan = PanManager.pan, !pan.isEmpty {
                RootView() // <-- Show homepage if PAN exists
            } else {
                ContentView_welcome()  // <-- Show welcome if PAN is missing
            }
        }
        .modelContainer(sharedModelContainer)
    }
}


