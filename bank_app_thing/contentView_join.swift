//
//  contentView1.swift
//  War Card Game
//
//  Created by lewis mills on 25/03/2025.
//

import SwiftUI

struct contentView_join: View {
    @StateObject private var viewModel = UserDetailsViewModel()
    @State private var PAN = "10"
    
    var body: some View {
        VStack {
            if let userDetails = viewModel.userDetails {
                Text("First Name: \(userDetails.FirstName)")
                Text("Last Name: \(userDetails.LastName)")
                Text("Email: \(userDetails.Email)")
                Text("Address: \(userDetails.Address)")
                Text("Mobile Number: \(userDetails.balance)")
                Text("Card Number: \(userDetails.CardNumber)")
                Text("Ledger Entry: \(String(userDetails.LedgerEntry))")
                Text("Overdraft State: \(String(userDetails.Overdraftstate))")
                Text("Overdraft Total: \(String(userDetails.Overdraft_total))")
                Text("Opened: \(userDetails.opened)")
                Text("Status: \(String(userDetails.status))")
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("Fetching user details...")
            }
        }
        
        .padding()
    }
    
}

struct contentView_join_Previews: PreviewProvider {
    static var previews: some View {
        contentView_join()
    }
}
