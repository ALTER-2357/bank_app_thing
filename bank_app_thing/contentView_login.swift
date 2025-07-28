import SwiftUI
import SwiftData

@MainActor
class LoginViewModel: ObservableObject {
    @Published var pan: String = ""
    @Published var Email: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var userDetails: UserDetails?

    let modelContext: ModelContext

    init(modelContext: ModelContext = ModelContext(SwiftDataContainer.shared.container)) {
        self.modelContext = modelContext
    }

    func login() {
        errorMessage = nil
        Task {
            await logintoFuzznyEngma(Email: Email)
        }
    }

    private func logintoFuzznyEngma(Email: String) async {
        guard let url = URL(string: "http://localhost:3031/login?Email=\(Email)") else {
            await updateError("Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(UserDetails.self, from: data)
            self.userDetails = decodedData
            self.isAuthenticated = true
            saveToSwiftDataStore(decodedData)
        } catch {
            await updateError("Failed to fetch or decode user data: \(error.localizedDescription)")
        }
    }

    private func fetchUserDataStore(pan: String) async {
        guard let url = URL(string: "http://localhost:3031/UserDetails?PAN=\(pan)") else {
            await updateError("Invalid URL")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decodedData = try JSONDecoder().decode(UserDetails.self, from: data)
                self.userDetails = decodedData
                self.isAuthenticated = true
                saveToSwiftDataStore(decodedData)
            } else {
                // Decode the error as a JSON string
                if let errorMessage = try? JSONDecoder().decode(String.self, from: data) {
                    print("Server error message: \(errorMessage)")
                    await updateError("Server error: \(errorMessage)")
                } else {
                    // Fallback if decoding fails
                    let fallbackError = String(data: data, encoding: .utf8) ?? "Unknown server error"
                    print("Server error message: \(fallbackError)")
                    await updateError("Server error: \(fallbackError)")
                }
            }
        } catch {
            await updateError("Failed to fetch or decode user data: \(error.localizedDescription)")
        }
        
    }

    @MainActor
    private func updateError(_ message: String) async {
        self.errorMessage = message
        self.isAuthenticated = false
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
                overdraftTotal: userDetails.Overdraft_total,
                pan: userDetails.PAN
            )
            modelContext.insert(newEntry)
            try modelContext.save()
        } catch {
            Task { @MainActor in
                self.errorMessage = "Failed to save user locally: \(error.localizedDescription)"
            }
        }
    }

    func logout() {
        pan = ""
        isAuthenticated = false
        userDetails = nil
        errorMessage = nil
    }

    // --- Added refresh code here ---
    @MainActor
    func refresh() async {
        guard isAuthenticated, let email = userDetails?.Email else { return }
        guard let url = URL(string: "http://localhost:3031/login?Email=\(email)") else {
            await updateError("Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(UserDetails.self, from: data)
            self.userDetails = decodedData
            saveToSwiftDataStore(decodedData)
        } catch {
            await updateError("Failed to refresh user data: \(error.localizedDescription)")
        }
    }
    // ---
}

struct LoginView: View {
    @ObservedObject var auth: AuthManager
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var panFieldIsFocused: Bool
    @State private var navigateToHomepage = false

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
                // NavigationLink triggers navigation to ContentViewHomepage when navigateToHomepage is true
                NavigationLink(
                    destination: ContentViewHomepage(auth: auth),
                    isActive: $navigateToHomepage,
                    label: { EmptyView() }
                )
                .hidden()
            }
            .onChange(of: viewModel.isAuthenticated) { newValue in
                if newValue {
                    auth.pan = viewModel.pan
                    Task {
                        await viewModel.refresh() // <-- Correct function call
                        navigateToHomepage = true
                    }
                }
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
            Text("Email")
                .font(.headline)
                .foregroundColor(Color.color0) // Make sure Color.color0 exists

            TextField("Enter your email", text: $viewModel.Email)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.color0.opacity(0.2), lineWidth: 1)
                )
                .keyboardType(.asciiCapable)
                .focused($panFieldIsFocused)
                .submitLabel(.go)
                .onSubmit { viewModel.login() }
                .foregroundColor(.black)
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
                .background(viewModel.Email.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.08), radius: 2, x: 0, y: 2)
        }
        .disabled(viewModel.Email.isEmpty)
        .padding(.top, 8)
    }
}

// email to server the server will respond with 200 ok and pan or 300? denided
