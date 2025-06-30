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

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
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

