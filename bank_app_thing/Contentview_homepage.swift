import SwiftUI
import Combine
import SwiftData

// MARK: - Model

class Contentview_homepageModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var cards: Cards?
    @Published var userDetails: UserDetails?
    @Published var ledgerEntries: [LedgerEntry] = []
    @Published var errorMessage: String?
    @Published var payees: [Payee] = []
    let modelContext: ModelContext

    init(modelContext: ModelContext = ModelContext(SwiftDataContainer.shared.container)) {
        self.modelContext = modelContext
    }

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
        guard let encodedPan = pan.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:3031/UserDetails?PAN=\(encodedPan)") else {
            Task { @MainActor in
                self.errorMessage = "Invalid URL"
                print("Invalid URL")
            }
            return
        }
        print("Fetching from URL: \(url.absoluteString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
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

    class SwiftDataContainer {
        static let shared = SwiftDataContainer()
        let container: ModelContainer

        private init() {
            do {
                container = try ModelContainer(for: SwiftDataStore.self)
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }

    func submitUserEditToServer(details: UserDetails) {
        guard let url = URL(string: "http://localhost:3031/ReviewUserEdit") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let data = try JSONEncoder().encode(details)
            request.httpBody = data
            URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    print("Failed to submit edit: \(error)")
                } else {
                    print("Edit submitted for review.")
                }
            }.resume()
        } catch {
            print("Encoding error: \(error)")
        }
    }
}

// MARK: - Main View

struct ContentViewHomepage: View {
    @ObservedObject var auth: AuthManager
    @StateObject private var viewModel = Contentview_homepageModel()
    @State private var showSettings = false
    @State private var showMenu = false
    @State private var selectedPayee: Payee? = nil
    @State private var showReview: Bool = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    topBar
                    Spacer(minLength: 0)
                    if let pan = auth.pan, !pan.isEmpty {
                        if let userDetails = viewModel.userDetails {
                            cardInfoSection(userDetails: userDetails)
                        }
                        payeeCardCarousel
                        transactionsSection
                    }
                }
                if showMenu { hamburgerMenu }
                if showSettings { settingsOverlay }
            }
            .background(LinearGradient(
                gradient: Gradient(colors: [Color(.systemGroupedBackground), Color(.systemGray6)]),
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea())
            .onAppear(perform: fetchAll)
            .onReceive(timer) { _ in fetchAll() }
            .navigationBarBackButtonHidden(true)
            .animation(.easeInOut, value: showSettings)
            .animation(.easeInOut, value: showMenu)
        }
    }
}



// MARK: - Subviews and Sections

extension ContentViewHomepage {
    // Top navigation bar
     var topBar: some View {
        HStack {
            Button {
                withAnimation { showMenu.toggle() }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 28, weight: .semibold))
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .padding(.leading, 18)

            Spacer()

            Button {
                withAnimation { showSettings = true }
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 24, weight: .medium))
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .padding(.trailing, 18)
        }
        .padding(.vertical, 10)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
    }

    // Card Info Section
     func cardInfoSection(userDetails: UserDetails) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.85),
                            Color.green.opacity(0.85)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(.systemGray4), radius: 10)
            VStack(alignment: .leading, spacing: 14) {
                if let cards = viewModel.cards {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Card Number")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.85))
                            Text(cards.CardNumber)
                                .font(.title2).bold().foregroundColor(.white)
                        }
                    }
                    Text("CVV: \(cards.CVV)   Expiry: \(cards.ExpiryDate)")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                } else {
                    Text("Loading card info…")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                Divider().background(.white.opacity(0.7))
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
                                .shadow(radius: 3)
                        )
                }
            }
            .padding(26)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 175)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // Payee Card Carousel - IMPROVED UI/UX
     var payeeCardCarousel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Favorite Payees")
                .font(.headline)
                .padding(.leading, 24)
                .padding(.top, 10)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.payees) { payee in
                        Button(action: {
                            selectedPayee = payee
                            showReview = true
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(width: 68, height: 68)
                                    Image("default_payee")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 54, height: 54)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                        .shadow(radius: 2)
                                }
                                Text(payee.payeeName)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .frame(width: 70)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 1, y: 1)
                                    .opacity(0.50)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
            }
        }
        .sheet(isPresented: $showReview) {
            if let payee = selectedPayee {
                TransferReviewView(payee: payee, isPresented: $showReview)
            }
        }
    }

    
    
    // Transactions Section
     var transactionsSection: some View {
        Group {
            if !viewModel.ledgerEntries.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .padding(.leading, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    ScrollView {
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
                                            .shadow(color: Color(.systemGray3).opacity(0.12), radius: 5, x: 0, y: 2)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            if viewModel.ledgerEntries.count > maxToShow {
                                NavigationLink(destination: ContentView_Transactions()) {
                                    Text("See more")
                                        .font(.callout.weight(.medium))
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
                }
                .cornerRadius(18)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding(.leading)
            } else {
                HStack {
                    ProgressView()
                    Text("Loading…")
                        .foregroundColor(.gray)
                        .padding(.leading)
                }
                .padding(.leading)
                .onAppear(perform: fetchAll)
            }
        }
    }

    // Hamburger Menu Drawer with overlay
     var hamburgerMenu: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showMenu = false } }
            HStack {
                SideMenuView()
                    .frame(width: 270)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 12, x: 2)
                    .transition(.move(edge: .leading))
                Spacer()
            }
            .ignoresSafeArea()
        }
    }

    
    // Helper to fetch all on appear/timer
    func fetchAll() {
        if let pan = auth.pan, !pan.isEmpty {
            viewModel.fetchLedgerEntries(pan: pan)
            viewModel.fetchUserDataStore(pan: pan)
            viewModel.fetchCards(pan: pan)
            viewModel.fetchPayees(pan: pan)
        }
    }
    
    
    // Settings Overlay           SideMenuView()
     var settingsOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showSettings = false } }
            HStack {
                Spacer()
                SettingsView(authManager: auth)
                    .frame(width: 330)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 12, x: -2)
                    .transition(.move(edge: .trailing))
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Example SideMenuView (dummy, replace as needed)
struct SideMenuView: View {
    @State private var showOverdraftSheet = false
    @State private var showRecurringSheet = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Menu")
                .font(.title2)
                .bold()
                .padding(.top, 60)

            Button(action: {
                showOverdraftSheet = true
            }) {
                HStack {
                    Image(systemName: "creditcard")
                        .font(.headline)
                    Text("Manage Overdraft")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity )
            }
            .frame(height: 54)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .sheet(isPresented: $showOverdraftSheet) {
                OverdraftManagementView(isPresented: $showOverdraftSheet)
            }

            Button(action: {
                showRecurringSheet = true
            }) {
                HStack {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.headline)
                    Text("Manage Recurring Payment")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 54)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .sheet(isPresented: $showRecurringSheet) {
                DirectDebitsView(isPresented: $showRecurringSheet)
            }

            Spacer()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
    }
}
