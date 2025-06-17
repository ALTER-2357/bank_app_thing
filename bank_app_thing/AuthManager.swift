import Foundation
import SwiftData
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    private var cancellables = Set<AnyCancellable>()

    @Published var pan: String? = nil

    private var modelContext: ModelContext

    init(modelContext: ModelContext = ModelContext(SwiftDataContainer.shared.container)) {
        self.modelContext = modelContext

        // Watch for changes to the SwiftData store
        fetchPan()

        // Listen for changes in SwiftData (simulate by polling or add publisher if you have one)
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchPan()
            }
            .store(in: &cancellables)
    }

    func fetchPan() {
        let descriptor = FetchDescriptor<SwiftDataStore>()
        do {
            let users = try modelContext.fetch(descriptor)
            let foundPan = users.first?.pan
            if foundPan != pan {
                pan = foundPan
            }
            isAuthenticated = !(foundPan?.isEmpty ?? true)
        } catch {
            pan = nil
            isAuthenticated = false
        }
    }

    func logout() {
        let descriptor = FetchDescriptor<SwiftDataStore>()
        do {
            let users = try modelContext.fetch(descriptor)
            for user in users {
                modelContext.delete(user)
            }
            try modelContext.save()
        } catch {
            // Ignore
        }
        pan = nil
        isAuthenticated = false
    }
}