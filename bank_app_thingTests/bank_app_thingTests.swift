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
        // Test that AuthManager properly clears authentication state on logout
        let authManager = AuthManager()
        
        // Simulate authenticated state
        authManager.pan = "test_pan_123"
        authManager.isAuthenticated = true
        PanManager.pan = "test_pan_123"
        
        // Verify initial state
        #expect(authManager.isAuthenticated == true)
        #expect(authManager.pan == "test_pan_123")
        #expect(PanManager.pan == "test_pan_123")
        
        // Call logout
        authManager.logout()
        
        // Verify logout clears all authentication state
        #expect(authManager.isAuthenticated == false)
        #expect(authManager.pan == nil)
        #expect(PanManager.pan == nil)
    }

}
