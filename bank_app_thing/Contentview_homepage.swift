import SwiftUI
import Combine
import SwiftData

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
                    self.ledgerEntries = Array(decodedData.prefix(1000))
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
            let allUsers = try modelContext.fetch(fetchAllDescriptor)
            for user in allUsers {
                modelContext.delete(user)
            }
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

struct ContentViewHomepage: View {
    @ObservedObject var auth: AuthManager
    @StateObject private var viewModel = Contentview_homepageModel()
    @State private var showSeeMore = false
    @State private var showSettings = false
    @State private var showOverdraftSheet = false

    // Timer to refresh data every 10 seconds
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Button { } label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.gray)
                                .font(.system(size: 25))
                        }
                        .padding(.leading, 15)

                        Spacer()

                        Button {
                            withAnimation {
                                showSettings = true
                            }
                        } label: {
                            Image(systemName: "gear")
                                .foregroundColor(.gray)
                                .font(.system(size: 25))
                        }
                        .padding(.trailing, 15)
                    }
                    .padding(.vertical, 12)

                    Spacer(minLength: 0)

                    if let pan = auth.pan, !pan.isEmpty {
                        if let userDetails = viewModel.userDetails {
                            VStack(alignment: .leading, spacing: 22) {
                                // Card Info
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.13, green: 0.52, blue: 1.00),
                                                    Color(red: 0.37, green: 0.72, blue: 1.00)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color(.systemGray4), radius: 8)
                                    VStack(alignment: .leading, spacing: 14) {
                                        if let cards = viewModel.cards {
                                            Text("Card Number")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.85))
                                            Text(cards.CardNumber)
                                                .font(.title3).bold()
                                                .foregroundColor(.white)
                                            Text("CVV: \(cards.CVV)   Expiry: \(cards.ExpiryDate)")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.85))
                                        } else {
                                            Text("Loading card info…")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        HStack {
                                            Text("Balance")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.85))
                                            Spacer()
                                            Text("£\(userDetails.balance)")
                                                .font(.title.bold())
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 6)
                                                .background(
                                                    Capsule()
                                                        .fill(userDetails.balance.contains("-") ? Color.red : Color.green)
                                                )
                                        }
                                    }
                                    .padding(28)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .padding(.horizontal)
                                .padding(.top, 6)

                                // Overdraft management button
                                Button(action: {
                                    showOverdraftSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "creditcard")
                                            .font(.headline)
                                        Text("Manage Overdraft")
                                            .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .sheet(isPresented: $showOverdraftSheet) {
                                    OverdraftManagementView(isPresented: $showOverdraftSheet)
                                }
                            }
                        }
                        // ---- Payees Carousel ----
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 24) {
                                ForEach(0..<3) { _ in
                                    Button(action: { }) {
                                        Image("default_payee")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 62, height: 62)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.blue, lineWidth: 3)
                                            )
                                            .background(
                                                Circle()
                                                    .fill(Color(.systemBackground))
                                                    .shadow(radius: 2)
                                            )
                                    }
                                }
                                Button(action: {}) {
                                    ZStack {
                                        Circle()
                                            .strokeBorder(Color.blue, lineWidth: 3)
                                            .background(Circle().fill(Color(.systemGray5)))
                                            .frame(width: 62, height: 62)
                                        Image(systemName: "plus")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical)
                        }

                        // ---- Transactions ----
                        Group {
                            if !viewModel.ledgerEntries.isEmpty {
                                ScrollView {
                                    Text("Recent Transactions")
                                        .font(.headline)
                                        .padding(.leading)
                                    VStack(spacing: 10) {
                                        let maxToShow = 10
                                        let entriesToShow = Array(viewModel.ledgerEntries.prefix(maxToShow))
                                        ForEach(entriesToShow.indices, id: \.self) { index in
                                            let entry = entriesToShow[index]
                                            NavigationLink(destination: ContentView_Detailed_Transaction(entry: entry)) {
                                                HStack(spacing: 16) {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(entry.MerchantName)
                                                            .font(.headline)
                                                            .foregroundColor(.primary)
                                                        Text(entry.Date)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                        if !entry.Description.isEmpty {
                                                            Text(entry.Description)
                                                                .font(.caption2)
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                    Spacer()
                                                    Text("£\(entry.Amount)")
                                                        .font(.headline.weight(.bold))
                                                        .foregroundColor(entry.Amount.contains("-") ? .red : .green)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(
                                                            Capsule()
                                                                .fill(entry.Amount.contains("-") ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                                                        )
                                                }
                                                .padding(.vertical, 8)
                                                .padding(.horizontal)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .fill(Color(.systemBackground))
                                                        .shadow(color: Color(.systemGray3).opacity(0.15), radius: 4, x: 0, y: 2)
                                                )
                                            }
                                        }
                                        if viewModel.ledgerEntries.count > maxToShow {
                                            NavigationLink(destination: ContentView_Transactions()) {
                                                Text("See more")
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 10)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color.blue.opacity(0.15))
                                                    )
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            } else if let errorMessage = viewModel.errorMessage {
                                Text("Error: \(errorMessage)")
                                    .foregroundColor(.red)
                                    .padding(.leading)
                            } else {
                                Text("Loading…")
                                    .foregroundColor(.gray)
                                    .padding(.leading)
                            }
                        }
                        Spacer(minLength: 0)
                    } else if let errorMessage = viewModel.errorMessage {
                        Spacer()
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Spacer()
                        ProgressView("Loading data…")
                            .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                if let pan = auth.pan, !pan.isEmpty {
                    viewModel.fetchLedgerEntries(pan: pan)
                    viewModel.fetchUserDataStore(pan: pan)
                    viewModel.fetchCards(pan: pan)
                }
            }
            .onReceive(timer) { _ in
                if let pan = auth.pan, !pan.isEmpty {
                    viewModel.fetchLedgerEntries(pan: pan)
                    viewModel.fetchUserDataStore(pan: pan)
                    viewModel.fetchCards(pan: pan)
                }
            }

            // SETTINGS OVERLAY
            if showSettings {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showSettings = false
                        }
                    }

                HStack {
                    Spacer()
                    SettingsView(authManager: auth)
                        .frame(width: 320)
                        .background(
                            Color(.systemBackground)
                                .shadow(radius: 8)
                        )
                        .transition(.move(edge: .trailing))
                }
                .ignoresSafeArea()
            }
        }
        .animation(.easeInOut, value: showSettings)
    }
}

