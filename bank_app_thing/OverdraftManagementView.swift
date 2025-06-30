import SwiftUI

// MARK: - Server Model
struct OverdraftResponse: Decodable {
    let balance: String
    let overdraftTotal: String
    let overdraftState: String
    let overdraftLeft: String

    enum CodingKeys: String, CodingKey {
        case balance = "balance"
        case overdraftTotal = "Overdraft_total"
        case overdraftState = "Overdraftstate"
        case overdraftLeft = "OverdraftLeft"
    }
}

// MARK: - View
struct OverdraftManagementView: View {
    @Binding var isPresented: Bool
    @State private var currentLimit: Double?
    @State private var newLimit: String = ""
    @State private var showConfirmation = false
    @State private var showSuccess = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isFetching = false
    @State private var lastFetchedInfo: OverdraftResponse?

    // NEW: State for raise overdraft limit
    @State private var showRaiseLimitSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Overdraft Limit")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    if let limit = currentLimit {
                        Text("£\(String(format: "%.2f", limit))")
                            .font(.title)
                            .bold()
                            .foregroundColor(.blue)
                    } else if isFetching {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Unable to load")
                            .foregroundColor(.red)
                    }
                    if let info = lastFetchedInfo {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Balance: £\(info.balance)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Overdraft Left: £\(info.overdraftLeft)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("State: \(info.overdraftState == "1" ? "Active" : "Inactive")")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 24)

                // NEW: Raise Overdraft Button (red)
                Button(action: {
                    showRaiseLimitSheet = true
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.headline)
                        Text("Raise Overdraft Limit")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showRaiseLimitSheet) {
                    RaiseOverdraftLimitSheet(
                        isPresented: $showRaiseLimitSheet,
                        currentLimit: currentLimit ?? 0.0
                    )
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Request to lower your overdraft limit")
                        .font(.headline)
                    TextField("Enter new limit", text: $newLimit)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                        )
                    Text("Note: Your request will be reviewed by our team.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.callout)
                }

                Spacer()

                Button(action: {
                    if isValidLimit() {
                        showConfirmation = true
                    } else {
                        errorMessage = "Please enter a valid amount (greater than 0 and different from current limit)"
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                        }
                        Text("Submit Request")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(isLoading || isFetching)
            }
            .navigationTitle("Overdraft Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Confirm Overdraft Change", isPresented: $showConfirmation) {
                Button("Submit", role: .none) {
                    submitOverdraftChange()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Request overdraft limit change to £\(newLimit).")
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    isPresented = false
                }
            } message: {
                Text("Your overdraft request has been submitted.")
            }
            .onAppear {
                fetchCurrentLimit()
            }
        }
    }

    // MARK: - Validation
    private func isValidLimit() -> Bool {
        guard let value = Double(newLimit), value > 0, let current = currentLimit, value != current else { return false }
        return true
    }

    // MARK: - Networking
    private func fetchCurrentLimit() {
        isFetching = true
        errorMessage = nil
        let userPan = PanManager.pan ?? ""
        guard let url = URL(string: "http://localhost:3031/OverDraftManagement?PAN=\(userPan)") else {
            self.errorMessage = "Invalid overdraft URL."
            self.isFetching = false
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isFetching = false
                if let error = error {
                    self.errorMessage = "Failed to fetch limit: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.errorMessage = "No data returned."
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let overdraftInfo = try decoder.decode(OverdraftResponse.self, from: data)
                    self.lastFetchedInfo = overdraftInfo
                    if let limit = Double(overdraftInfo.overdraftTotal) {
                        self.currentLimit = limit
                    } else {
                        self.errorMessage = "Invalid overdraft value"
                    }
                } catch {
                    if let jsonString = String(data: data, encoding: .utf8),
                       let jsonData = jsonString.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let overdraftInfo = try decoder.decode(OverdraftResponse.self, from: jsonData)
                            self.lastFetchedInfo = overdraftInfo
                            if let limit = Double(overdraftInfo.overdraftTotal) {
                                self.currentLimit = limit
                            } else {
                                self.errorMessage = "Invalid overdraft value"
                            }
                        } catch {
                            self.errorMessage = "Error parsing response: \(error.localizedDescription)\nRaw: \(jsonString)"
                        }
                    } else {
                        self.errorMessage = "Error parsing response: \(error.localizedDescription)"
                    }
                }
            }
        }
        task.resume()
    }

    private func submitOverdraftChange() {
        errorMessage = nil
        isLoading = true
        let userPan = PanManager.pan ?? ""
        let requestedLimit = newLimit

        guard let url = URL(string: "http://localhost:3031/OverDraftManagement?PAN=\(userPan)&NewLimit=\(requestedLimit)") else {
            self.errorMessage = "Invalid overdraft URL."
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 403 {
                        self.errorMessage = "Your overdraft increase request was rejected."
                        return
                    }
                    if !(200...299).contains(httpResponse.statusCode) {
                        self.errorMessage = "Request failed (code \(httpResponse.statusCode))."
                        return
                    }
                }
                self.showSuccess = true
                self.fetchCurrentLimit()
            }
        }
        task.resume()
    }
}

// MARK: - Raise Overdraft Limit Sheet
struct RaiseOverdraftLimitSheet: View {
    @Binding var isPresented: Bool
    var currentLimit: Double

    @State private var requestedLimit: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showConfirmation = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Raise Overdraft Limit")
                    .font(.title2)
                    .bold()
                    .padding(.top, 16)

                Text("Current Limit: £\(String(format: "%.2f", currentLimit))")
                    .foregroundColor(.secondary)

                TextField("Enter new higher limit", text: $requestedLimit)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.callout)
                }

                Spacer()

                Button(action: {
                    if isValidRaise() {
                        showConfirmation = true
                    } else {
                        errorMessage = "Please enter a valid higher amount."
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text("Request Increase")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(isLoading)
            }
            .navigationTitle("Raise Overdraft Limit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Confirm Raise", isPresented: $showConfirmation) {
                Button("Submit", role: .none) {
                    submitRaiseRequest()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Request overdraft limit increase to be £\(requestedLimit).")
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    isPresented = false
                }
            } message: {
                Text("Your overdraft increase request has been submitted.")
            }
        }
    }

    private func isValidRaise() -> Bool {
        guard let value = Double(requestedLimit), value > currentLimit else { return false }
        return true
    }

    private func submitRaiseRequest() {
        errorMessage = nil
        isLoading = true
        let userPan = PanManager.pan ?? ""
        let requested = requestedLimit

        guard let url = URL(string: "http://localhost:3031/OverDraftManagement?PAN=\(userPan)&NewLimit=\(requested)") else {
            self.errorMessage = "Invalid overdraft URL."
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 403 {
                        self.errorMessage = "Your overdraft increase request was rejected."
                        return
                    }
                    if !(200...299).contains(httpResponse.statusCode) {
                        self.errorMessage = "Request failed (code \(httpResponse.statusCode))."
                        return
                    }
                }
                self.showSuccess = true
            }
        }
        task.resume()
    }
}
