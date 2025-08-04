//
//  DirectDebit.swift
//  bank_app_thing
//
//  Created by lewis mills on 04/08/2025.
//


import SwiftUI

struct DirectDebit: Codable, Identifiable {
    var id: Int { DDpan }
    let Name: String
    let Amount: Float
    let DDpan: Int
    let ShortCode: Int
    let date: Int
}

class DirectDebitsViewModel: ObservableObject {
    @Published var directDebits: [DirectDebit] = []
    @Published var errorMessage: String?

    func fetchDirectDebits(pan: String) {
        guard !pan.isEmpty else { return }
        guard let url = URL(string: "http://localhost:3031/directdebits?PAN=\(pan)") else {
            DispatchQueue.main.async { self.errorMessage = "Invalid URL" }
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = "Error: \(error.localizedDescription)" }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { self.errorMessage = "No data received" }
                return
            }
            do {
                let decodedData = try JSONDecoder().decode([DirectDebit].self, from: data)
                DispatchQueue.main.async {
                    self.directDebits = Array(decodedData.prefix(1000))
                }
            } catch {
                do {
                    let singleDebit = try JSONDecoder().decode(DirectDebit.self, from: data)
                    DispatchQueue.main.async {
                        self.directDebits = [singleDebit]
                    }
                } catch {
                    DispatchQueue.main.async { self.errorMessage = "Decoding error: \(error.localizedDescription)" }
                }
            }
        }.resume()
    }
}

struct DirectDebitsView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = DirectDebitsViewModel()
    let pan = PanManager.pan ?? ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                VStack(spacing: 0) {
                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color(.systemRed).opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    if viewModel.directDebits.isEmpty && viewModel.errorMessage == nil {
                        ProgressView("Loading Direct Debits…")
                            .padding()
                    }
                    List {
                        ForEach(viewModel.directDebits) { debit in
                            NavigationLink(destination: DirectDebitDetailView(directDebit: debit)) {
                                DirectDebitRow(directDebit: debit)
                            }
                            .listRowBackground(Color(.secondarySystemGroupedBackground))
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Direct Debits")
            .onAppear { viewModel.fetchDirectDebits(pan: pan) }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct DirectDebitRow: View {
    let directDebit: DirectDebit

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "creditcard")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.accentColor)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(directDebit.Name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Payee: \(directDebit.DDpan)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("£\(String(format: "%.1f", directDebit.Amount))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .background(Color.green.opacity(0.15))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}



struct DirectDebitDetailView: View {
    let directDebit: DirectDebit

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 44))
                        .foregroundColor(.accentColor)
                    VStack(alignment: .leading) {
                        Text(directDebit.Name)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Payee")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                VStack(spacing: 16) {
                    InfoRow(
                        icon: "sterlingsign.circle",
                        label: "Amount",
                        value: "£\(directDebit.Amount)"
                    )
                    InfoRow(icon: "creditcard.fill", label: "DDpan", value: "\(directDebit.DDpan)")
                    InfoRow(icon: "number", label: "Short Code", value: "\(directDebit.ShortCode)")
                    InfoRow(icon: "clock", label: "date", value: "\(directDebit.date)")
                    
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
                .padding(.vertical)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Direct Debit")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 28)
            Text(label)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .font(.body.monospacedDigit())
                .foregroundColor(.primary)
        }
        .padding(.vertical, 6)
    }
}