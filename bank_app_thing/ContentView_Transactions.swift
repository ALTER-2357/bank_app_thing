import SwiftUI
import Combine

// MARK: - Model
struct LedgerEntry: Codable, Identifiable {
    let Id: Int
    let PAN: String
    let MerchantID: String
    let MerchantName: String
    let hash: String
    let TransactionID: String
    let Date: String
    let Amount: String
    let Description: String
    let Balance: String
    let SpendToday: String
    let OverdraftLeft: String

    var id: Int { Id }
}

// MARK: - ViewModel

class ContentView_TransactionsModel: ObservableObject {
    @Published var ledgerEntries: [LedgerEntry] = []
    @Published var errorMessage: String?

    func fetchLedgerEntries(pan: String) {
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
                    self.ledgerEntries = []
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.ledgerEntries = []
                }
                return
            }

            do {
                let decodedData = try JSONDecoder().decode([LedgerEntry].self, from: data)
                DispatchQueue.main.async {
                    self.ledgerEntries = Array(decodedData.prefix(100000))
                    self.errorMessage = self.ledgerEntries.isEmpty ? "No payees found" : nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                    self.ledgerEntries = []
                }
            }
        }.resume()
    }
}

// MARK: - View

struct ContentView_Transactions: View {
    @StateObject private var viewModel = ContentView_TransactionsModel()
    @State private var pan: String = PanManager.pan ?? ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Transactions")
                    .font(.largeTitle).bold()
                    .padding([.top, .horizontal])
            
                  if !viewModel.ledgerEntries.isEmpty {
                    List {
                        ForEach(viewModel.ledgerEntries) { entry in
                            NavigationLink(destination: ContentView_Detailed_Transaction(entry: entry)) {
                                TransactionListRow(entry: entry)
                            }
                            .listRowBackground(Color(.systemBackground))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchLedgerEntries(pan: pan)
                    }
                } else {
                    // Loading state
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView("You don't have any payees yet, create one by clicking the plus button")
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                    Spacer()
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                viewModel.fetchLedgerEntries(pan: pan)
            }
        }
    }
}

// MARK: - Transaction Row Styling

struct TransactionListRow: View {
    let entry: LedgerEntry

    var amountColor: Color {
        entry.Amount.contains("-") ? .red : .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.MerchantName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(entry.Date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("£\(entry.Amount)")
                    .font(.title3).bold()
                    .foregroundColor(amountColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(amountColor.opacity(0.1))
                    )
            }
            if !entry.Description.isEmpty {
                Text(entry.Description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .shadow(color: Color(.systemGray5), radius: 2, x: 0, y: 1)
    }
}



