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
        print("Login triggered for PAN: \(pan)")
        fetchUserDataStore(pan: pan)
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

    private func saveToSwiftDataStore(_ userDetails: UserDetails) {
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
                VStack(spacing: 32) {
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.color0)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PAN")
                            .font(.headline)
                            .foregroundColor(.color0)
                        TextField("Enter PAN", text: $viewModel.pan)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.asciiCapable)
                            .focused($panFieldIsFocused)
                            .submitLabel(.go)
                            .onSubmit { viewModel.login() }
                            .foregroundColor(.black)
                        
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("Login")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .foregroundColor(.color0)
                    }
                    .disabled(viewModel.pan.isEmpty)
                    
                    Spacer()
                }
                .padding()
                .onAppear { panFieldIsFocused = true }
                .onChange(of: viewModel.isAuthenticated) { newValue in
                    if newValue {
                        // AuthManager will pick up the change (via polling or publisher)
                    }
                }
            }
        }
    }
}



/*

import SwiftUI

struct contentView_login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var FirstName: String = ""
    @State private var LastName: String = ""
    @State private var Address: String = ""
    @State private var MobileNumber: String = ""
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.color1)
                    .ignoresSafeArea()
                VStack {
                    // Login Header
                    Text("Welcome back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 250)
                        .padding(.bottom, 40)
                    // Email Field
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .onSubmit {
                            print("Email submitted: \(email)")
                        }
        
                        .padding(.bottom, 40)
                    
                    Button(action: {
                        print("Login button pressed")
                        print("Attempting login with:")
                        print("Email: \(email)")
                    }) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal )
                      
                    }
                   
                    Spacer()
                    
                }
            }
        }
    }
}

struct ContentView_login_Previews: PreviewProvider {
    static var previews: some View {
        contentView_login()
    }
}
*/
