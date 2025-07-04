//
//  TransferReviewView.swift
//  bank_app_thing
//
//  Created by lewis mills on 23/06/2025.
//

import SwiftUI

struct TransferReviewView: View {
    let payee: Payee
    @Binding var isPresented: Bool
    @State private var amount: String = ""
    @State private var showConfirmation = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Transfer to")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(payee.payeeName)
                        .font(.title)
                        .bold()
                    Text("Shortcode: \(payee.shortCode)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("PAN: \(payee.payeesPan)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.top, 24)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Amount")
                        .font(.headline)
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.callout)
                }
                
                Spacer()
                
                Button(action: {
                    if isValidAmount() {
                        showConfirmation = true
                    } else {
                        errorMessage = "Please enter a valid amount (greater than 0)"
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                        }
                        Text("Continue")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(isLoading)
            }
            .navigationTitle("Review Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Confirm Transfer", isPresented: $showConfirmation) {
                Button("Send", role: .none) {
                    sendPayment()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You are transferring £\(amount) to \(payee.payeeName).")
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    isPresented = false
                }
            } message: {
                Text("Payment successful!")
            }
        }
    }
    
    private func isValidAmount() -> Bool {
        guard let value = Double(amount), value > 0 else { return false }
        return true
    }
    
    private func sendPayment() {
        errorMessage = nil
        isLoading = true
        
        // Replace with actual user's PAN if available
        let userPan = PanManager.pan ?? ""
        let payeePan = payee.payeesPan
        let amountValue = amount
        
        guard let url = URL(string: "http://localhost:3031/userpayment?PAN=\(userPan)&PayeePan=\(payeePan)&Amount=\(amountValue)") else {
            self.errorMessage = "Invalid payment URL."
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    self.errorMessage = "Payment failed (code \(httpResponse.statusCode))."
                    return
                }
                // Optionally, parse data for success/failure here
                self.showSuccess = true
            }
        }
        task.resume()
    }
}
