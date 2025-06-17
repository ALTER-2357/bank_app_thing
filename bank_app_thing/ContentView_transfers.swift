//
//  Contentview_homepage.swift
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
}

// MARK: - ViewModel

class Contentview_transfersModel: ObservableObject {
    @Published var payees: [Payee] = []
    @Published var errorMessage: String?

    func fetchPayees(pan: Int) {
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

// MARK: - View

struct Contentview_transfers: View {
    @StateObject private var viewModel = Contentview_transfersModel()
    @State private var pan = 10 // Example PAN

    var body: some View {
        VStack {
            ZStack {
                Text("payees")
                    .font(.title)
                HStack {
                    Spacer()
                    Button(action: {
                      
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            if !viewModel.payees.isEmpty {
                List(viewModel.payees) { payee in
                    VStack(alignment: .leading, spacing: 6) {
                        Button(action: {
                           
                        }) {
                            VStack(alignment: .leading, spacing: 6){
                                Text("Payee Name: \(payee.payeeName)")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                HStack{ Text("Payees Pan: \(payee.payeesPan)")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 30))
                                        .foregroundColor(.black)
                                }
                                Text("ShortCode: \(payee.shortCode)")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.vertical, 4)
                        }

                        
                  
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            viewModel.fetchPayees(pan: pan)
        }
    }
}

struct Contentview_transfers_Previews: PreviewProvider {
    static var previews: some View {
        Contentview_transfers()
    }
}


