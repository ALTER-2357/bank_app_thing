import SwiftUI

struct SettingsView: View {
    @ObservedObject var authManager: AuthManager
    @State private var navigateToWelcome = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ZStack {
                    Spacer()
                    Text("SettingsView")
                        .font(.title)
                }

                Button(role: .destructive) {
                    authManager.logout()
                    navigateToWelcome = true
                } label: {
                    Text("Log Out")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Hidden NavigationLink to trigger navigation
                NavigationLink(
                    destination: ContentView_welcome(),
                    isActive: $navigateToWelcome,
                    label: { EmptyView() }
                )
                .hidden()
            }
        }
    }
}
