//
//  Contentview_homepage.swift
//  bank_app_thing
//
//  Created by lewis mills on 27/05/2025.
//

import SwiftUI
import Combine





class Contentview_homepageModel: ObservableObject {
    @Published var cards: Cards?
    @Published var userDetails: UserDetails?
    @Published var ledgerEntries: [LedgerEntry] = []
    @Published var errorMessage: String?


    func fetchLedgerEntries(pan: Int) {
        guard let url = URL(string :"http://localhost:3031/LedgerEntry?PAN=\(pan)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
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
                let decodedData = try JSONDecoder().decode([LedgerEntry].self, from: data)
                DispatchQueue.main.async {
                    self.ledgerEntries = Array(decodedData.prefix(5))
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    
    func fetchCards(pan: Int) {
        guard let url = URL(string: "http://localhost:3031/Cards?PAN=\(pan)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
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
                let decodedData = try JSONDecoder().decode(Cards.self, from: data)
                DispatchQueue.main.async {
                    self.cards = decodedData
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    
    
    func fetchUserDetails(pan: Int) {
        guard let url = URL(string: "http://localhost:3031/UserDetails?PAN=\(pan)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
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

// MARK: - View

struct Contentview_homepage: View {
    @StateObject private var viewModel = Contentview_homepageModel()
    @State private var pan = 10 // Example PAN
    
    var body: some View {
        VStack {
            if let userDetails = viewModel.userDetails {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Card Number: \(userDetails.CardNumber)")
                                .font(.headline)
                            if let cards = viewModel.cards {
                                Text("CVV: \(cards.CVV) Expiry Date:\(cards.ExpiryDate)")
                                    .font(.subheadline)
                            } else {
                                Text("Loading card info...")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Text("Balance: \(userDetails.balance)")
                                .font(.title2)
                                .padding(6)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
                                .foregroundColor(.white)
                        }
                    }
                    
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.2)))
                    Text("payees should go here")
                    VStack {
                        if !viewModel.ledgerEntries.isEmpty {
                            List(viewModel.ledgerEntries) { entry in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("TransactionID: \(entry.TransactionID)")
                                        .font(.headline)
                                    Text("Date: \(entry.Date)")
                                        .font(.subheadline)
                                    Text("Amount: \(entry.Amount)")
                                        .font(.subheadline)
                                    Text("Description: \(entry.Description)")
                                        .font(.body)
                                }
                                .padding(.vertical, 4)
                            }
                        } else if let errorMessage = viewModel.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else {
                            Text("Loading...")
                        }
                    }
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("Loading data...")
                    .padding()
            }
        }
        .onAppear {
            viewModel.fetchLedgerEntries(pan: pan)
            viewModel.fetchUserDetails(pan: pan)
            viewModel.fetchCards(pan: pan)
        }
    }
}

struct Contentview_homepage_Previews: PreviewProvider {
    static var previews: some View {
        Contentview_homepage()
    }
}
