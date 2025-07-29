import SwiftUI

struct SettingsView: View {
    @ObservedObject var authManager: AuthManager
    @State private var navigateToWelcome = false

    var body: some View {
        NavigationStack {
            VStack {
                
                ZStack {
                    Text("Settings")
                        .font(.title)
                        .padding(.top, 80)
                }

                NavigationLink(destination: UserDetailsView()) {
                    Text("Edit User Details")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

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
