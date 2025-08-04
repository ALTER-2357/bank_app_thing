import SwiftUI


// MARK: - Main Chat Detail View
struct ChatDetailView: View {
    // Inputs
    let pan: String
    let help_request_id: Int

    // State
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var error: String?
    @State private var newMessage: String = ""
    @State private var isSending = false

    // MARK: - View Body
    var body: some View {
        VStack {
            // Title
            Text("Support Chat")
                .font(.title2)
                .padding(.top)

            // Messages List
            if isLoading {
                ProgressView("Loading messages…")
                    .padding()
            } else if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                
            } else if messages.isEmpty {
                Text("No messages yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(messages) { msg in
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text("\(msg.first_name) \(msg.last_name)")
                                            .bold()
                                        Spacer()
                                        Text(msg.created)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    Text(msg.message)
                                        .font(.body)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                .id(msg.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        // Scroll to bottom when new message arrives
                        if let last = messages.last {
                            scrollProxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Spacer()

            // Chat Box
            HStack(alignment: .bottom) {
                TextEditor(text: $newMessage)
                    .frame(minHeight: 36, maxHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .disabled(isSending)
                Button(action: {
                    sendMessage()
                }) {
                    if isSending {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 44, height: 44)
                .background(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending ? Color.gray : Color.blue)
                .cornerRadius(8)
                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            }
            .padding([.horizontal, .bottom])
        }
        .onAppear { fetchMessages() }
    }

    // MARK: - Networking

    func fetchMessages() {
        error = nil
        isLoading = true
        var components = URLComponents(string: "http://localhost:3031/CustomerServicesgetchat")!
        components.queryItems = [
            .init(name: "PAN", value: pan),
            .init(name: "help_message_from_user", value: newMessage),
            .init(name: "help_request_id", value: String(help_request_id))
        ]
        let url = components.url!
        let task = URLSession.shared.dataTask(with: url) { data, _, err in
            DispatchQueue.main.async {
                isLoading = false
                if let err = err {
                    error = "Failed to load: \(err.localizedDescription)"
                    messages = []
                    return
                }
                guard let data = data else {
                    error = "No data received"
                    messages = []
                    return
                }
                do {
                    messages = try JSONDecoder().decode([ChatMessage].self, from: data)
                } catch {
                    self.error = "Failed to decode: \(error.localizedDescription)"
                    messages = []
                }
            }
        }
        task.resume()
    }

    func sendMessage() {
        guard !isSending && !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSending = true
        // Assuming sending a message is a POST – adjust endpoint if needed
        var components = URLComponents(string: "http://localhost:3031/CustomerServicesgetchat")!
        components.queryItems = [
            .init(name: "PAN", value: pan),
            .init(name: "help_message_from_user", value: newMessage),
            .init(name: "help_request_id", value: String(help_request_id))
        ]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { _, _, err in
            DispatchQueue.main.async {
                isSending = false
                if let err = err {
                    error = "Failed to send message: \(err.localizedDescription)"
                } else {
                    newMessage = ""
                    fetchMessages() // Refresh chat after send
                }
            }
        }
        task.resume()
    }
}

// MARK: - Preview
struct ChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailView(pan: "acc_111", help_request_id: 123)
    }
}
