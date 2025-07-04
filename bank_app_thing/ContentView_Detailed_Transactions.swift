//
//  ContentView_Detailed_Transaction.swift
//  bank_app_thing
//
//  Created by Copilot on 20/06/2025.
//

import SwiftUI

// MARK: - Detailed Transaction View

struct ContentView_Detailed_Transaction: View {
    let entry: LedgerEntry
    @State private var isRefunding: Bool = false
    @State private var refundResult: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Transaction Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Merchant")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(entry.MerchantName)
                            .font(.title2)
                            .bold()
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Amount")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(entry.Amount)")
                            .font(.title2)
                            .foregroundColor(entry.Amount.contains("-") ? .black : .green)
                            .bold()
                    }
                }

                Divider()

                // Transaction Details
                Group {
                    DetailRow(label: "Transaction ID", value: entry.TransactionID)
                    DetailRow(label: "Date & Time", value: entry.Date)
                    DetailRow(label: "Merchant ID", value: entry.MerchantID)
                    DetailRow(label: "PAN", value: entry.PAN)
                    DetailRow(label: "Hash", value: entry.hash)
                }

                Divider()

                // Description
                Group {
                    Text("Description")
                        .font(.headline)
                    Text(entry.Description)
                        .font(.body)
                        .padding(.bottom, 8)
                }

                Divider()

                // Account Balances
                Group {
                    HStack(spacing: 20) {
                        BalanceCard(title: "Balance After", value: entry.Balance)
                        BalanceCard(title: "Spend Today", value: entry.SpendToday)
                        BalanceCard(title: "Overdraft Left", value: entry.OverdraftLeft)
                    }
                }

                Divider()
                
                // Refund Button
                if entry.Amount.contains("-") == false && entry.Description.lowercased().contains("refund") == false {
                    Button(action: {
                        refundTransaction()
                    }) {
                        HStack {
                            if isRefunding {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            Text("Refund")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isRefunding)
                }
                
                // Refund Result feedback
                if let refundResult = refundResult {
                    Text(refundResult)
                        .font(.callout)
                        .foregroundColor(refundResult.lowercased().contains("success") ? .green : .red)
                        .padding(.top, 4)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Refund Handler
    private func refundTransaction() {
        self.isRefunding = true
        self.refundResult = nil
        // Construct URL and make network request to refund endpoint
        guard let url = URL(string: "http://localhost:3031/PaymentGateway/Refund") else {
            self.refundResult = "Invalid refund URL."
            self.isRefunding = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let params = [
            "TransactionID": entry.TransactionID,
            "MerchantID": entry.MerchantID,
            "Amount": entry.Amount.replacingOccurrences(of: "£", with: "") // Remove currency symbol if present
        ]
        request.httpBody = params
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isRefunding = false
                if let error = error {
                    self.refundResult = "Refund failed: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.refundResult = "No response from server."
                    return
                }
                let serverResponse = String(data: data, encoding: .utf8) ?? "Unknown response"
                if serverResponse.lowercased().contains("completed") || serverResponse.lowercased().contains("success") {
                    self.refundResult = "Refund successful!"
                } else {
                    self.refundResult = "Refund failed: \(serverResponse)"
                }
            }
        }.resume()
    }
}



struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.body)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
    }
}

struct BalanceCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("£\(value)")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 1)
    }
}
