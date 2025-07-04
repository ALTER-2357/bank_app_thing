//
//  AuthManager.swift
//  bank_app_thing
//
//  Created by AI Assistant on 2025
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUserPAN: String?
    
    private let userDefaults = UserDefaults.standard
    private let panKey = "PAN"
    
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Status
    
    func checkAuthenticationStatus() {
        currentUserPAN = userDefaults.string(forKey: panKey)
        isLoggedIn = currentUserPAN != nil && !currentUserPAN!.isEmpty
    }
    
    // MARK: - Login
    
    func login(pan: String) {
        userDefaults.set(pan, forKey: panKey)
        currentUserPAN = pan
        isLoggedIn = true
    }
    
    // MARK: - Logout
    
    func logout() {
        // Clear UserDefaults
        userDefaults.removeObject(forKey: panKey)
        
        // Clear any other stored session data if needed
        clearOtherSessionData()
        
        // Update state
        currentUserPAN = nil
        isLoggedIn = false
        
        print("User logged out successfully")
    }
    
    // MARK: - Helper Methods
    
    private func clearOtherSessionData() {
        // Clear any cached data or temporary files
        // This could include clearing specific SwiftData entries if needed
        // For now, we'll focus on UserDefaults
        
        // You could add more cleanup here such as:
        // - Clearing temporary files
        // - Resetting app state
        // - Clearing cached user data
    }
    
    func getCurrentUserPAN() -> String? {
        return currentUserPAN
    }
    
    func clearAllUserData(modelContext: ModelContext) {
        // Optionally clear SwiftData if complete logout is needed
        do {
            let fetchDescriptor = FetchDescriptor<SwiftDataStore>()
            let storedUsers = try modelContext.fetch(fetchDescriptor)
            for user in storedUsers {
                modelContext.delete(user)
            }
            try modelContext.save()
            print("All user data cleared from SwiftData")
        } catch {
            print("Error clearing user data: \(error.localizedDescription)")
        }
    }
}

// MARK: - Singleton Access (Optional)
extension AuthManager {
    static let shared = AuthManager()
}