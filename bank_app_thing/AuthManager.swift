import Foundation
import SwiftData
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var pan: String? = nil

    private var cancellables = Set<AnyCancellable>()
    private var modelContext: ModelContext

    // UserDefaults PAN key
    private static let panKey = "pan"

    init(modelContext: ModelContext = ModelContext(SwiftDataContainer.shared.container)) {
        self.modelContext = modelContext

        // Initial fetch (from SwiftData or UserDefaults)
        fetchPan()

        // Keep polling SwiftData for changes (simulate reactivity)
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchPan()
            }
            .store(in: &cancellables)
    }

    // MARK: - Persistence (UserDefaults)

    private func savePanToUserDefaults(_ pan: String?) {
        if let pan = pan {
            UserDefaults.standard.set(pan, forKey: Self.panKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.panKey)
        }
    }

    private func loadPanFromUserDefaults() -> String? {
        UserDefaults.standard.string(forKey: Self.panKey)
    }

    // MARK: - SwiftData Fetch

    func fetchPan() {
        let descriptor = FetchDescriptor<SwiftDataStore>()
        do {
            let users = try modelContext.fetch(descriptor)
            let foundPan = users.first?.pan

            // Prefer SwiftData. If not available, fall back to UserDefaults.
            let currentPan = foundPan ?? loadPanFromUserDefaults()
            if currentPan != pan {
                pan = currentPan
            }
            isAuthenticated = !(currentPan?.isEmpty ?? true)

            // Keep UserDefaults up-to-date with SwiftData
            savePanToUserDefaults(currentPan)
        } catch {
            // If error, fall back to UserDefaults
            let storedPan = loadPanFromUserDefaults()
            pan = storedPan
            isAuthenticated = !(storedPan?.isEmpty ?? true)
        }
    }

    // MARK: - Set PAN
    
    func setPan(_ newPan: String) {
        // Update local state
        pan = newPan
        isAuthenticated = !newPan.isEmpty
        
        // Save to UserDefaults
        savePanToUserDefaults(newPan)
        
        // The polling timer will update SwiftData when user data is fetched
        // This ensures the PAN is immediately available for authentication
    }

    // MARK: - Logout

    func logout() {
        let descriptor = FetchDescriptor<SwiftDataStore>()
        do {
            let users = try modelContext.fetch(descriptor)
            for user in users {
                modelContext.delete(user)
            }
            try modelContext.save()
        } catch {
            // Ignore errors
        }
        pan = nil
        isAuthenticated = false
        savePanToUserDefaults(nil)
    }

    // MARK: - Global (static) PAN access

    static var globalPan: String? {
        UserDefaults.standard.string(forKey: panKey)
    }
}
