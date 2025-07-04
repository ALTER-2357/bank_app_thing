//
//  bank_app_thingTests.swift
//  bank_app_thingTests
//
//  Created by lewis mills on 27/01/2025.
//

import Testing
@testable import bank_app_thing

struct bank_app_thingTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func testAuthManagerLogout() async throws {
        // Create an AuthManager instance
        let authManager = AuthManager()
        
        // First login with a test PAN
        let testPAN = "12345"
        authManager.login(pan: testPAN)
        
        // Verify user is logged in
        #expect(authManager.isLoggedIn == true)
        #expect(authManager.getCurrentUserPAN() == testPAN)
        
        // Now logout
        authManager.logout()
        
        // Verify user is logged out
        #expect(authManager.isLoggedIn == false)
        #expect(authManager.getCurrentUserPAN() == nil)
        
        // Verify UserDefaults is cleared
        let storedPAN = UserDefaults.standard.string(forKey: "PAN")
        #expect(storedPAN == nil)
    }

}
