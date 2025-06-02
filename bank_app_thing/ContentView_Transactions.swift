//
//  ContentView_Transactions.swift
//  bank_app_thing
//
//  Created by lewis mills on 30/05/2025.
//

import SwiftUI
import Combine

// MARK: - Model
struct LedgerEntry: Codable, Identifiable {
    // These names must exactly match the JSON keys (case-sensitive)
    let Id: Int
    let PAN: String
    let MerchantID: String
    let hash: String
    let TransactionID: String
    let Date: String
    let Amount: String
    let Description: String
    let Balance: String
    let SpendToday: String
    let OverdraftLeft: String

    var id: Int { Id } // For Identifiable conformance
}

// MARK: - ViewModel

class ContentView_TransactionsModel: ObservableObject {
    @Published var ledgerEntries: [LedgerEntry] = []
    @Published var errorMessage: String?

    func fetchLedgerEntries(pan: Int) {
        guard let url = URL(string: "http://localhost:3031/LedgerEntry?PAN=\(pan)") else {
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
}

// MARK: - View

struct ContentView_Transactions: View {
    @StateObject private var viewModel = ContentView_TransactionsModel()
    @State private var pan = 10 // Example PAN

    var body: some View {
        VStack {
            if !viewModel.ledgerEntries.isEmpty {
                List(viewModel.ledgerEntries) { entry in
                    VStack(alignment: .leading, spacing: 6 ) {
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
        .onAppear {
            viewModel.fetchLedgerEntries(pan: pan)
        }
    }
}

struct ContentView_Transactions_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_Transactions()
    }
}
