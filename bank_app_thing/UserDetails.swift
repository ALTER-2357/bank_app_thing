//
//  UserDetails.swift
//  bank_app_thing
//
//  Created by lewis mills on 15/04/2025.
//


import SwiftUI
import Combine

// Model to decode the JSON response
struct UserDetails: Codable {
    let Address: String
    let CardNumber: String
    let Email: String
    let FirstName: String
    let LastName: String
    let LedgerEntry: String
    let balance: String
    let Overdraft_total: String
    let Overdraftstate: String
    let PAN: String
    let opened: String
    let status: String
}


struct Cards: Codable {
    let PAN: String
    let CardHolder: String
    let CardNumber: String
    let CVV: String
    let ExpiryDate: String
    let Status: String
    let Pin: String
}


/*
struct LedgerEntry: Codable {
    let id: Int
    let pan: String
    let merchantID: String
    let hash: String
    let transactionID: String
    let date: String
    let amount: String
    let description: String
    let balance: String
    let spendToday: String
    let overdraftLeft: String
}
*/
    class UserDetailsViewModel: ObservableObject {
        @Published var userDetails: UserDetails?
        @Published var errorMessage: String?
        
        func fetchUserDetails(pan: Int) {
            guard let url = URL(string: "http://localhost:3031/UserDetails?PAN=\(pan)") else {
                self.errorMessage = "Invalid URL"
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No data received"
                    }
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(UserDetails.self, from: data)
                    DispatchQueue.main.async {
                        self.userDetails = decodedData
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Decoding error: \(error.localizedDescription)"
                    }
                }
            }.resume()
        }
    }
    
    
    
    struct UserDetailsView: View {
        @StateObject private var viewModel = UserDetailsViewModel()
        @State private var pan = 10 // Example PAN
        
        var body: some View {
            VStack {
                if let userDetails = viewModel.userDetails {
                    //permanet data // well data that dosent change ever minite
                    /*
                     Text("First Name: \(userDetails.FirstName)")
                     Text("Last Name: \(userDetails.LastName)")
                     Text("Email: \(userDetails.Email)")
                     Text("Address: \(userDetails.Address)")
                     Text("Card Number: \(userDetails.CardNumber)")
                     Text("PAN: \(userDetails.PAN)")
                     Text("Opened: \(userDetails.opened)")
                     */
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("First Name: \(userDetails.FirstName)")
                        Text("Last Name: \(userDetails.LastName)")
                        Text("Email: \(userDetails.Email)")
                        Text("balance: \(userDetails.balance)")
                        Text("Address: \(userDetails.Address)")
                        Text("Card Number: \(userDetails.CardNumber)")
                        Text("Ledger Entry: \(userDetails.LedgerEntry)")
                        Text("Overdraft Total: \(userDetails.Overdraft_total)")
                        Text("Overdraft State: \(userDetails.Overdraftstate)")
                        Text("PAN: \(userDetails.PAN)")
                        Text("Opened: \(userDetails.opened)")
                        Text("Status: \(userDetails.status)")
                    }
                    .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Press the button to load data")
                        .padding()
                }
                
                Button(action: {
                    viewModel.fetchUserDetails(pan: pan)
                }) {
                    Text("Request Data")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
    
    
    struct UserDetailsView_Previews: PreviewProvider {
        static var previews: some View {
            UserDetailsView()
        }
    }

