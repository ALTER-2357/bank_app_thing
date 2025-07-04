import SwiftUI
import SwiftData
import Combine

@Model
class PermanentUserDetailsQuery: Identifiable {
    var firstName: String
    var lastName: String
    var pan: String

    init(firstName: String, lastName: String, pan: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.pan = pan
    }
}
struct Cards: Codable {
    let PAN: String
    let CardHolder: String
    let CardNumber: String
    let CVV: String
    let ExpiryDate: String
    let Status: String
    let Pin: String
}

struct UserDetails: Codable {
    let Address: String
    let CardNumber: String
    let Email: String
    let FirstName: String
    let LastName: String
    let balance: String
    let MobileNumber: String
    let Overdraft_total: String
    let Overdraftstate: String
    let PAN: String
    let opened: String
    let status: String
}

@Model
class SwiftDataStore: Identifiable {
    var address: String
    var cardNumber: String
    var email: String
    var firstName: String
    var lastName: String
    var overdraftTotal: String
    var pan: String

    init(address: String, cardNumber: String, email: String, firstName: String, lastName: String, overdraftTotal: String, pan: String) {
        self.address = address
        self.cardNumber = cardNumber
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.overdraftTotal = overdraftTotal
        self.pan = pan
    }
}

@MainActor
class UserDetailsViewModel: ObservableObject {
    @Published var userDetails: UserDetails?
    @Published var errorMessage: String?
    @Published var permanentUser: PermanentUserDetailsQuery?

    // Add a published property for fetched stored data (if you want to display it)
    @Published var storedUserData: [SwiftDataStore] = []

    // Add the model context
    let modelContext: ModelContext

    init(modelContext: ModelContext = ModelContext(SwiftDataContainer.shared.container)) {
        self.modelContext = modelContext
    }

    func fetchUserDataStore(pan: String) {
            guard let url = URL(string: "http://localhost:3031/UserDetails?PAN=\(pan)") else {
                self.errorMessage = "Invalid URL"
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
                    let decodedData = try JSONDecoder().decode(UserDetails.self, from: data)
                    DispatchQueue.main.async {
                        self.userDetails = decodedData
                        self.saveToSwiftDataStore(decodedData)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Decoding error: \(error.localizedDescription)"
                    }
                }
            }.resume()
        }
    

    
    
    func fetchUserDetails(pan: String) {
        guard let url = URL(string: "http://localhost:3031/UserDetails?PAN=\(pan)") else {
            self.errorMessage = "Invalid URL"
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
                let decodedData = try JSONDecoder().decode(UserDetails.self, from: data)
                DispatchQueue.main.async {
                    self.userDetails = decodedData
                    self.saveToSwiftDataStore(decodedData)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    private func saveToSwiftDataStore(_ userDetails: UserDetails) {
        // 1. Check if a user with the same PAN already exists
        let fetchDescriptor = FetchDescriptor<SwiftDataStore>(
            predicate: #Predicate { $0.pan == userDetails.PAN }
        )

        do {
            let existingUsers = try modelContext.fetch(fetchDescriptor)
            if let existingUser = existingUsers.first {
                // 2. Compare all relevant fields
                let isSame = existingUser.address == userDetails.Address &&
                             existingUser.cardNumber == userDetails.CardNumber &&
                             existingUser.email == userDetails.Email &&
                             existingUser.firstName == userDetails.FirstName &&
                             existingUser.lastName == userDetails.LastName &&
                             existingUser.overdraftTotal == userDetails.Overdraft_total

                if isSame {
                    // Data is the same, don't insert or update
                    print("No changes detected, skipping save.")
                    return
                } else {
                    // Data is different, update the existing entry
                    existingUser.address = userDetails.Address
                    existingUser.cardNumber = userDetails.CardNumber
                    existingUser.email = userDetails.Email
                    existingUser.firstName = userDetails.FirstName
                    existingUser.lastName = userDetails.LastName
                    existingUser.overdraftTotal = userDetails.Overdraft_total
                    // No need to insert, just update fields
                    print("changes detected, now save.")
                }
            } else {
                // 3. Not found, insert as new
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
            }
            // 4. Save any changes
            try modelContext.save()
        } catch {
            self.errorMessage = "Failed to save to SwiftData: \(error.localizedDescription)"
        }
    }

    func fetchStoredUsers() {
        do {
            let fetchDescriptor = FetchDescriptor<SwiftDataStore>()
            self.storedUserData = try modelContext.fetch(fetchDescriptor)
        } catch {
            self.errorMessage = "Failed to fetch stored users: \(error.localizedDescription)"
        }
    }
}

// Singleton for SwiftData container, for simplicity
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

struct UserDetailsView: View {
    @StateObject private var viewModel: UserDetailsViewModel
    @State private var pan = ""
    @State private var showOnlyPermanent = false

    // Inject model context into the view model
    init() {
        let context = ModelContext(SwiftDataContainer.shared.container)
        _viewModel = StateObject(wrappedValue: UserDetailsViewModel(modelContext: context))
    }

    var body: some View {
        VStack {
            if showOnlyPermanent, let permanentUser = viewModel.permanentUser {
                VStack(alignment: .leading, spacing: 10) {
                    Text("First Name: \(permanentUser.firstName)")
                    Text("Last Name: \(permanentUser.lastName)")
                    Text("PAN: \(permanentUser.pan)")
                }
                .padding()
            } else if let userDetails = viewModel.userDetails {
                VStack(alignment: .leading, spacing: 10) {
                    Text("First Name: \(userDetails.FirstName)")
                    Text("Last Name: \(userDetails.LastName)")
                    Text("Email: \(userDetails.Email)")
                    Text("Balance: \(userDetails.balance)")
                    Text("Address: \(userDetails.Address)")
                    Text("Card Number: \(userDetails.CardNumber)")
                    Text("Overdraft Total: \(userDetails.Overdraft_total)")
                    Text("Overdraft State: \(userDetails.Overdraftstate)")
                    Text("PAN: \(userDetails.PAN)")
                    Text("Opened: \(userDetails.opened)")
                    Text("Status: \(userDetails.status)")
                }
                .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("Press the button to load data")
                    .padding()
            }

            HStack {
                TextField("Enter PAN", text: $pan)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: {
                    viewModel.fetchUserDetails(pan: pan)
                    showOnlyPermanent = false
                }) {
                    Text("Request Data")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()

            Button(action: {
                // Clear userDetails and error, but keep permanentUser
                viewModel.userDetails = nil
                viewModel.errorMessage = nil
                showOnlyPermanent = true
            }) {
                Text("Clear")
                    .font(.headline)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
            .disabled(viewModel.permanentUser == nil)

            Divider().padding(.vertical, 20)

            Button("Show Stored Users") {
                viewModel.fetchStoredUsers()
            }
            .padding(.bottom)

            if !viewModel.storedUserData.isEmpty {
                List(viewModel.storedUserData, id: \.pan) { stored in
                    VStack(alignment: .leading) {
                        Text("First Name: \(stored.firstName)")
                        Text("Last Name: \(stored.lastName)")
                        Text("Email: \(stored.email)")
                        Text("PAN: \(stored.pan)")
                        Text("Card Number: \(stored.cardNumber)")
                        Text("Address: \(stored.address)")
                        Text("Overdraft Total: \(stored.overdraftTotal)")
                    }
                }
                .frame(height: 300)
            }
        }
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView()
    }
}
