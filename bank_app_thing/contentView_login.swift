import SwiftUI
import SwiftData

@MainActor
class LoginViewModel: ObservableObject {
    @Published var pan: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var userDetails: UserDetails?

    let modelContext: ModelContext

    init(modelContext: ModelContext = ModelContext(SwiftDataContainer.shared.container)) {
        self.modelContext = modelContext
    }

    func login() {
        errorMessage = nil
        fetchUserDataStore(pan: pan)
    }

    private func fetchUserDataStore(pan: String) {
        guard let url = URL(string: "http://localhost:3031/UserDetails?PAN=\(pan)") else {
            updateError("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.updateError("Network error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                self.updateError("No data received from server.")
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(UserDetails.self, from: data)
                Task { @MainActor in
                    self.userDetails = decodedData
                    self.isAuthenticated = true
                    self.saveToSwiftDataStore(decodedData)
                }
            } catch {
                self.updateError("Failed to decode user data: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func updateError(_ message: String) {
        Task { @MainActor in
            self.errorMessage = message
            self.isAuthenticated = false
        }
    }

    private func saveToSwiftDataStore(_ userDetails: UserDetails) {
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
        } catch {
            updateError("Failed to save user locally: \(error.localizedDescription)")
        }
    }

    func logout() {
        pan = ""
        isAuthenticated = false
        userDetails = nil
        errorMessage = nil
    }
}



struct LoginView: View {
    @ObservedObject var auth: AuthManager
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var panFieldIsFocused: Bool

    init(auth: AuthManager) {
        self.auth = auth
        let context = ModelContext(SwiftDataContainer.shared.container)
        _viewModel = StateObject(wrappedValue: LoginViewModel(modelContext: context))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.color1)
                    .ignoresSafeArea()
                VStack(spacing: 36) {
                    header
                    panInputSection
                    if let errorMessage = viewModel.errorMessage {
                        errorText(errorMessage)
                    }
                    loginButton
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 60)
                .onAppear { panFieldIsFocused = true }
            }
        }
    }

    private var header: some View {
        Text("Login")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(.color0)
            .padding(.bottom, 10)
    }

    private var panInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PAN")
                .font(.headline)
                .foregroundStyle(.color0)
            TextField("Enter PAN", text: $viewModel.pan)
                .textFieldStyle(.plain)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.color0.opacity(0.2), lineWidth: 1)
                        .background(Color.white.cornerRadius(8))
                )
                .keyboardType(.asciiCapable)
                .focused($panFieldIsFocused)
                .submitLabel(.go)
                .onSubmit { viewModel.login() }
                .foregroundColor(.black)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 2)
        }
    }

    private func errorText(_ error: String) -> some View {
        Text(error)
            .foregroundColor(.red)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.vertical, 4)
            .transition(.opacity)
    }

    private var loginButton: some View {
        Button(action: {
            viewModel.login()
        }) {
            Text("Login")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.pan.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.08), radius: 2, x: 0, y: 2)
        }
        
        .disabled(viewModel.pan.isEmpty)
        .padding(.top, 8)
    }
}


