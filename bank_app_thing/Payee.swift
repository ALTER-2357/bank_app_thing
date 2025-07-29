//
//  Payee.swift
//  bank_app_thing
//
//  Created by lewis mills on 31/07/2025.
//


//
//  Contentview_transfers.swift
//  bank_app_thing
//
//  Created by lewis mills on 27/05/2025.
//

import SwiftUI
import Combine

// MARK: - Model

struct Payee: Identifiable, Codable {
    var id: String { payeesPan }
    let payeeName: String
    let payeesPan: String
    let shortCode: String
    let favorite: Int
}

// MARK: - ViewModel

class Contentview_transfersModel: ObservableObject {
    @Published var payees: [Payee] = []
    @Published var errorMessage: String?

    func fetchPayees(pan: String) {
        guard let url = URL(string: "http://localhost:3031/Get_Payees?PAN=\(pan)") else {
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
                let decodedData = try JSONDecoder().decode([Payee].self, from: data)
                DispatchQueue.main.async {
                    self.payees = Array(decodedData.prefix(5))
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// MARK: - Main Transfers View

struct Contentview_transfers: View {
    @StateObject private var viewModel = Contentview_transfersModel()
    @State private var pan: String = PanManager.pan ?? ""
    @State private var selectedPayee: Payee? = nil
    @State private var showReview = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Text("transfers")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: {
                        // Show the payee review view with a "new" blank payee or trigger add-payee logic
                        // For demonstration, let's show a blank TransferReviewView
                        selectedPayee = nil
                        showReview = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Add payee")
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)

                // Payees List
                if viewModel.payees.isEmpty {
                    VStack {
                        Spacer()
                        Text("You don't have any payees yet,")
                            .foregroundColor(.secondary)
                        Text("create one by clicking the plus button.")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else if !viewModel.payees.isEmpty {
                    List {
                        ForEach(viewModel.payees) { payee in
                            Button(action: {
                                selectedPayee = payee
                                showReview = true
                            }) {
                                HStack(alignment: .center, spacing: 12) {
                                    // Icon or avatar placeholder
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Image("default_payee")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 48, height: 48)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.gray, lineWidth: 3)
                                                )
                                                .background(
                                                    Circle()
                                                        .fill(Color(.systemBackground))
                                                        .shadow(radius: 2)
                                                )
                                        )
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(payee.payeeName)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("Shortcode: \(payee.shortCode)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("PAN: \(payee.payeesPan)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 20, weight: .semibold))
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(.plain)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .font(.body.bold())
                        Spacer()
                    }
                } else {
                    VStack(spacing: 16) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Loading payees...")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                viewModel.fetchPayees(pan: pan)
            }
            .sheet(isPresented: $showReview) {
                // Show review for existing or new payee
                if let payee = selectedPayee {
                    TransferReviewView(payee: payee, isPresented: $showReview)
                } else {
                    // If adding a new payee, present an empty/new TransferReviewView
                    TransferReviewView(payee: nil, isPresented: $showReview)
                }
            }
        }
    }
}

// Dummy PanManager for code completeness
struct PanManager {
    static var pan: String? = "1234567890"
}

// Dummy TransferReviewView for preview/demo
struct TransferReviewView: View {
    var payee: Payee?
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text(payee?.payeeName ?? "Add New Payee")
                .font(.title)
                .padding()
            Button("Close") {
                isPresented = false
            }
            .padding()
        }
    }
}
