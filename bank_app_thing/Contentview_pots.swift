//
//  Contentview_pots.swift
//  bank_app_thing
//
//  Created by lewis mills on 02/06/2025.
//

import SwiftUI
import Combine

// MARK: - Model

struct Pot: Identifiable, Codable {
    var id: String { Id }
    let Id: String
    let name: String
    let style: String
    let Balance: String
    let currency: String
    let interestRate: String
    let updated: String
    let created: String
    let deleted: String
    let RequestID: String
}

// MARK: - ViewModel

class Contentview_potsModel: ObservableObject {
    @Published var pots: [Pot] = []
    @Published var errorMessage: String?
    @Published var successMessage: String?

    func fetchPots(pan: String) {
        guard let url = URL(string: "http://localhost:3031/Pots?PAN=\(pan)") else {
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
                // Try to decode as an array first
                if let arr = try? JSONDecoder().decode([Pot].self, from: data) {
                    DispatchQueue.main.async { self.pots = arr }
                }
                // If that fails, try to decode as a single object
                else if let obj = try? JSONDecoder().decode(Pot.self, from: data) {
                    DispatchQueue.main.async { self.pots = [obj] }
                }
                else {
                    print("RAW JSON:", String(data: data, encoding: .utf8) ?? "nil")
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Not a Pot or [Pot]"))
                }
            } catch {
                print("RAW JSON:", String(data: data, encoding: .utf8) ?? "nil")
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    /// Create a new Pot using POST with query parameters (not JSON body)
    func createPot(
        pan: String,
        name: String,
        style: String,
        amount: String,
        currency: String,
        interestRate: String,
        completion: (() -> Void)? = nil
    ) {
        // Construct the query string as required by the server
        let urlString = "http://localhost:3031/Pots?PAN=\(pan)&name=\(name)&style=\(style)&Amount=\(amount)&currency=\(currency)&InterestRate=\(interestRate)"
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "POST Error: \(error.localizedDescription)"
                }
                return
            }

            // Optional: Check status code
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self.errorMessage = "Server returned status code \(httpResponse.statusCode)"
                }
                return
            }

            // Try to decode the returned pot (if your backend returns it)
            if let data = data, let newPot = try? JSONDecoder().decode(Pot.self, from: data) {
                DispatchQueue.main.async {
                    self.pots.append(newPot)
                    self.successMessage = "Pot created successfully!"
                    completion?()
                }
                return
            }

            // If backend doesn't return a Pot, just show success and refresh
            DispatchQueue.main.async {
                self.successMessage = "Pot created successfully!"
                completion?()
                // Optionally, refresh list:
                // self.fetchPots(pan: pan)
            }
        }.resume()
    }
}

// MARK: - View

struct Contentview_pots: View {
    @StateObject private var viewModel = Contentview_potsModel()
    @State private var pan: String = PanManager.pan ?? ""

    // For demo: fields to create a new pot
    @State private var newPotName = ""
    @State private var newPotStyle = ""
    @State private var newPotAmount = ""
    @State private var newPotCurrency = ""
    @State private var newPotInterestRate = ""
    @State private var showingCreatePotForm = false

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Text("Pots")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    // Action for adding payee (to be implemented)
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

            // CONTENT (always below header)
            Group {
                Spacer()
                if viewModel.errorMessage != nil {
                    VStack {
                        Text("You don't have any Pots yet,")
                            .foregroundColor(.secondary)
                        Text("create one by clicking the plus button.")
                            .foregroundColor(.secondary)
                    }
                } else if !viewModel.pots.isEmpty {
                    List(viewModel.pots) { pot in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Pot Name: \(pot.name)")
                                .font(.headline)
                            HStack {
                                Text("Balance: \(pot.Balance)")
                                    .font(.subheadline)
                                Text("Interest Rate: \(pot.interestRate)")
                                    .font(.headline)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("Loading...")
                        .padding()
                }
            }

            if showingCreatePotForm {
                VStack(spacing: 8) {
                    Text("Create New Pot").font(.headline)
                    TextField("Name", text: $newPotName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Style", text: $newPotStyle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Amount", text: $newPotAmount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Currency", text: $newPotCurrency)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Interest Rate", text: $newPotInterestRate)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Create Pot") {
                        viewModel.createPot(
                            pan: pan,
                            name: newPotName,
                            style: newPotStyle,
                            amount: newPotAmount,
                            currency: newPotCurrency,
                            interestRate: newPotInterestRate
                        ) {
                            // Clear fields and hide form on success
                            newPotName = ""
                            newPotStyle = ""
                            newPotAmount = ""
                            newPotCurrency = ""
                            newPotInterestRate = ""
                            showingCreatePotForm = false
                            viewModel.fetchPots(pan: pan)
                        }
                    }
                    .padding(.top, 4)

                    if let success = viewModel.successMessage {
                        Text(success)
                            .foregroundColor(.green)
                    }
                }
                .padding()
            }

            Spacer()
        }
        .onAppear {
            viewModel.fetchPots(pan: pan)
        }
    }
}

struct Contentview_pots_Previews: PreviewProvider {
    static var previews: some View {
        Contentview_pots()
    }
}
