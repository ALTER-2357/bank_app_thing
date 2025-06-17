import SwiftUI
import Combine
import _SwiftData_SwiftUI
import CryptoKit

// MARK: - HomePage ViewModel

class Contentview_homepageModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var cards: Cards?
    @Published var userDetails: UserDetails?
    @Published var ledgerEntries: [LedgerEntry] = []
    @Published var errorMessage: String?
    let modelContext: ModelContext
    
    init(modelContext: ModelContext = ModelContext(SwiftDataContainer.shared.container)) {
        self.modelContext = modelContext
    }
    

    func fetchLedgerEntries(pan: String) {
        guard !pan.isEmpty else { return }
        guard let url = URL(string: "http://localhost:3031/LedgerEntry?PAN=\(pan)") else {
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
                let decodedData = try JSONDecoder().decode([LedgerEntry].self, from: data)
                DispatchQueue.main.async {
                    self.ledgerEntries = Array(decodedData.prefix(5))
                }
            } catch {
                DispatchQueue.main.async { self.errorMessage = "Decoding error: \(error.localizedDescription)" }
            }
        }.resume()
    }

    func fetchCards(pan: String) {
        guard !pan.isEmpty else { return }
        guard let url = URL(string: "http://localhost:3031/Cards?PAN=\(pan)") else {
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
                let decodedData = try JSONDecoder().decode(Cards.self, from: data)
                DispatchQueue.main.async {
                    self.cards = decodedData
                }
            } catch {
                DispatchQueue.main.async { self.errorMessage = "Decoding error: \(error.localizedDescription)" }
            }
        }.resume()
    }
        
      
        
        
        func fetchUserDataStore(pan: String) {
            guard let url = URL(string: "http://localhost:3031/UserDetails?PAN=\(pan)") else {
                self.errorMessage = "Invalid URL"
                print("Invalid URL")
                return
            }
            print("Fetching from URL: \(url.absoluteString)")
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                // Always print the status for debugging
                print("Network response received")
                if let error = error {
                    Task { @MainActor in
                        self.errorMessage = "Error: \(error.localizedDescription)"
                        print(self.errorMessage ?? "Unknown error")
                    }
                    return
                }
                
                guard let data = data else {
                    Task { @MainActor in
                        self.errorMessage = "No data received"
                        print("No data received")
                    }
                    return
                }
                
                // Debug: Print raw response
                print("Raw response: \(String(data: data, encoding: .utf8) ?? "nil")")
                
                do {
                    let decodedData = try JSONDecoder().decode(UserDetails.self, from: data)
                    Task { @MainActor in
                        print("Decoded user details for PAN: \(decodedData.PAN)")
                        self.userDetails = decodedData
                        self.isAuthenticated = true
                        self.saveToSwiftDataStore(decodedData)
                    }
                } catch {
                    Task { @MainActor in
                        self.errorMessage = "Decoding error: \(error.localizedDescription)"
                        print(self.errorMessage ?? "Unknown decode error")
                    }
                }
            }.resume()
        }
        
        func saveToSwiftDataStore(_ userDetails: UserDetails) {
            print("Saving user to SwiftDataStore: \(userDetails.PAN)")
            let fetchAllDescriptor = FetchDescriptor<SwiftDataStore>()
            
            do {
                // Fetch and delete all users
                let allUsers = try modelContext.fetch(fetchAllDescriptor)
                for user in allUsers {
                    modelContext.delete(user)
                }
                
                // Insert the new user
                let newEntry = SwiftDataStore(
                    address: userDetails.Address,
                    cardNumber: userDetails.CardNumber,
                    email: userDetails.Email,
                    firstName: userDetails.FirstName,
                    lastName: userDetails.LastName,
                    ledgerEntry: userDetails.LedgerEntry,
                    overdraftTotal: userDetails.Overdraft_total,
                    pan: userDetails.PAN
                )
                modelContext.insert(newEntry)
                
                try modelContext.save()
                print("Successfully saved user.")
            } catch {
                self.errorMessage = "Failed to save to SwiftData: \(error.localizedDescription)"
                print(self.errorMessage ?? "Unknown SwiftData error")
            }
        }
    }

// MARK: - Main HomePage View

import SwiftUI
import SwiftData

struct ContentViewHomepage: View {
    @ObservedObject var auth: AuthManager
    @StateObject private var viewModel = Contentview_homepageModel()
    
    var body: some View {
        NavigationStack {
            HStack{
                Button(action: {
                    // Action can be added here if needed in the future
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.gray)
                        .font(.system(size: 25))
                }
                .padding(.leading, 15)
                
                Spacer()
                
                Button(action: {
                    // Action can be added here if needed in the future
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.gray)
                        .font(.system(size: 25))
                }
                .padding(.trailing, 15)
            }
            .padding(.bottom, 10)
            .padding(.top, 10)
            Spacer()
            
            VStack {
                if let pan = auth.pan, !pan.isEmpty {
                    // User is authenticated and PAN is present
                    if let userDetails = viewModel.userDetails {
                        VStack {
                            HStack {
                                VStack(alignment: .leading ) {
                                    
                                    Text("Card Number: \(userDetails.CardNumber)")
                                        .font(.headline)
                                    if let cards = viewModel.cards {
                                        Text("CVV: \(cards.CVV)  Expiry Date: \(cards.ExpiryDate)")
                                            .font(.subheadline)
                                    } else {
                                        Text("Loading card info…")
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
                            Text("your favorite payees")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 15 )
                                .padding(.top, 6)
                            
                            HStack{
                                
                                Button(action: {
                                    // Action can be added here if needed in the future
                                }) {
                                    Image("default_payee")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 64, height: 64) // Adjust size as needed
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 3)
                                        )
                                }
                                .padding(.leading, 15)
                                .padding(2)
                                Button(action: {
                                    // Action can be added here if needed in the future
                                }) {
                                    Image("default_payee")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 64, height: 64) // Adjust size as needed
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 3)
                                        )
                                }
                                .padding(2)
                                Button(action: {
                                    // Action can be added here if needed in the future
                                }) {
                                    Image("default_payee")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 64, height: 64) // Adjust size as needed
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 3)
                                        )
                                }
                                Button(action: {
                                    // Action can be added here if needed in the future
                                }) {
                                    //
                                    Image(systemName: "plus")
                                        .font(.system(size: 30))
                                        
                                        
                                        .frame(width: 64, height: 64) // Adjust size as needed
                                        .foregroundColor(.black)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black, lineWidth: 3)
                                        )
                                }
                                Spacer()
                            }
                            .padding(6)
                            VStack {
                                if !viewModel.ledgerEntries.isEmpty {
                                    List(viewModel.ledgerEntries) { entry in
                                        VStack(alignment: .leading, spacing: 6 ) {
                                            HStack{
                                                Text("Merchants Name: \(entry.MerchantName)")
                                                Spacer()
                                                Text("Amount: £\(entry.Amount)")
                                                    .font(.subheadline)
                                            }
                                            .font(.headline)
                                            Text("Date: \(entry.Date)")
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
                                    Text("Loading…")
                                }
                            }
                        }
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text("Loading data…")
                            .padding()
                    }
                } else {
                    // This branch should rarely be hit, as the parent view should handle login!
                    Text("No PAN found. Please login.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .onAppear {
                if let pan = auth.pan, !pan.isEmpty {
                    viewModel.fetchLedgerEntries(pan: pan)
                    viewModel.fetchUserDataStore(pan: pan)
                    viewModel.fetchCards(pan: pan)
                }
            }
        }
        
    }
    
}
