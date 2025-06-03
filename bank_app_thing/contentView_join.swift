import SwiftUI
import SwiftData

import SwiftData
struct contentView_join: View {
    @Query private var storedUsers: [SwiftDataStore] // Fetch all SwiftDataStore entries
    @State private var refreshID = UUID() // Dummy state to trigger view refresh

    public init() {}
    var body: some View {
        NavigationView {
            VStack {
                Button("Recheck") {
                    // Changing refreshID will force the view to reload
                    refreshID = UUID()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())

                List(storedUsers, id: \.pan) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(user.firstName) \(user.lastName)").font(.headline)
                        Text("PAN: \(user.pan)").font(.subheadline)
                        Text("Email: \(user.email)")
                        Text("Card Number: \(user.cardNumber)")
                        Text("Address: \(user.address)")
                        Text("Overdraft Total: \(user.overdraftTotal)")
                    }
                    .padding(4)
                }
                .id(refreshID) // This will force the List to reload when refreshID changes
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Stored Users")
        }
    }
}

struct contentView_join_Previews: PreviewProvider {
    static var previews: some View {
        contentView_join()
    }
}
