import SwiftUI

struct ContentView_help: View {
    @State private var pan: String = PanManager.pan ?? ""
    @AppStorage("help_request_id") private var help_request_id: String = ""
    @State private var chatMessages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var error: String?
    @State private var newMessage: String = ""
    @State private var isSending = false
    @State private var hasStartedChat = false

    // Timer to trigger refresh every 0.5 seconds
    private let refreshTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !hasStartedChat {
                    // Default Help Page before chat starts
                    VStack(spacing: 30) {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .foregroundColor(.accentColor)
                            .padding(.top, 60)

                        Text("Need Help?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Welcome to our support center. You can browse common questions or start a chat with our team.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        // Show both buttons if a previous help_request_id exists
                        if !help_request_id.isEmpty {
                            VStack(spacing: 16) {
                                Button(action: {
                                    hasStartedChat = true
                                    fetchMessages()
                                }) {
                                    HStack {
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                        Text("Resume Previous Chat")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                                    .shadow(color: Color.orange.opacity(0.1), radius: 8, y: 2)
                                }
                                .padding(.horizontal, 40)

                                Button(action: {
                                    // Clear the previous chat and start a new one
                                    help_request_id = ""
                                    chatMessages = []
                                    startNewChat()
                                }) {
                                    HStack {
                                        Image(systemName: "plus.bubble.fill")
                                        Text("Start New Chat")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                                    .shadow(color: .accentColor.opacity(0.1), radius: 8, y: 2)
                                }
                                .padding(.horizontal, 40)
                            }
                        } else {
                            Button(action: {
                                startNewChat()
                            }) {
                                HStack {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                    Text("Start a Chat")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: .accentColor.opacity(0.1), radius: 8, y: 2)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    // Chat UI
                    VStack(spacing: 0) {
                        Text("Help & Support Chat")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                            .padding(.top, 16)
                            .padding(.bottom, 8)

                        Group {
                            if isLoading {
                                ProgressView("Loading messages…")
                                    .padding(.vertical, 40)
                            } else if let error = error {
                                Text(error)
                                    .foregroundColor(.red)
                                    .padding(.vertical, 40)
                                    .multilineTextAlignment(.center)
                            } else if chatMessages.isEmpty {
                                Text("No messages yet.")
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 40)
                            } else {
                                ScrollViewReader { scrollProxy in
                                    ScrollView {
                                        LazyVStack(alignment: .leading, spacing: 14) {
                                            ForEach(chatMessages) { msg in
                                                ChatBubble(message: msg)
                                                    .id(msg.id)
                                            }
                                        }
                                        .padding([.horizontal, .top])
                                    }
                                    .onChange(of: chatMessages.count) { _ in
                                        if let last = chatMessages.last {
                                            withAnimation(.easeOut(duration: 0.22)) {
                                                scrollProxy.scrollTo(last.id, anchor: .bottom)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 1)

                        HStack(alignment: .bottom, spacing: 8) {
                            TextEditor(text: $newMessage)
                                .frame(minHeight: 38, maxHeight: 80)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                                )
                                .disabled(isSending)
                                .opacity(isSending ? 0.8 : 1.0)

                            Button(action: sendMessage) {
                                ZStack {
                                    if isSending {
                                        ProgressView().scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .frame(width: 44, height: 44)
                            .background(
                                (newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending) ?
                                Color.gray.opacity(0.6) : Color.blue
                            )
                            .cornerRadius(12)
                            .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                            .shadow(color: .blue.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground).opacity(0.97))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.04), radius: 2, y: -1)
                    }
                    .onAppear {
                        if !help_request_id.isEmpty {
                            hasStartedChat = true
                            fetchMessages()
                        }
                    }
                    .navigationTitle("Help Request #\(help_request_id)")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color(.secondarySystemGroupedBackground).ignoresSafeArea())
                }
            }
            // The timer is attached here, so it ALWAYS fires while the view is alive
            .onReceive(refreshTimer) { _ in
                if hasStartedChat {
                    fetchMessages()
                }
            }
        }
        
    }

    struct HelpRequestIDResponse: Decodable {
        let help_request_id: String
    }

    // MARK: - Networking

    func startNewChat() {
        guard let url = URL(string: "http://localhost:3031/CustomerServicesStartnewchat") else {
            error = "Invalid URL for starting chat."
            return
        }
        isLoading = true
        error = nil

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = "PAN=\(pan)"
        request.httpBody = bodyString.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, _, err in
            DispatchQueue.main.async {
                isLoading = false
                if let err = err {
                    error = "Failed to start chat: \(err.localizedDescription)"
                    return
                }
                guard let data = data else {
                    error = "No data received."
                    return
                }
                if let decoded = try? JSONDecoder().decode(HelpRequestIDResponse.self, from: data) {
                    help_request_id = decoded.help_request_id
                    hasStartedChat = true
                    fetchMessages()
                } else {
                    error = "Failed to parse help request ID."
                }
            }
        }
        task.resume()
    }

    func fetchMessages() {
        error = nil
        isLoading = true
        var components = URLComponents(string: "http://localhost:3031/CustomerServicesgetchat")!
        components.queryItems = [
            .init(name: "PAN", value: pan),
            .init(name: "help_message_from_user", value: ""),
            .init(name: "help_request_id", value: help_request_id)
        ]
        let url = components.url!
        let task = URLSession.shared.dataTask(with: url) { data, _, err in
            DispatchQueue.main.async {
                isLoading = false
                if let err = err {
                    error = "Failed to load: \(err.localizedDescription)"
                    chatMessages = []
                    return
                }
                guard let data = data else {
                    error = "No data received"
                    chatMessages = []
                    return
                }
                do {
                    chatMessages = try JSONDecoder().decode([ChatMessage].self, from: data)
                } catch {
                    self.error = "Failed to decode: \(error.localizedDescription)"
                    chatMessages = []
                }
            }
        }
        task.resume()
    }

    func sendMessage() {
        guard !isSending && !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSending = true

        var components = URLComponents(string: "http://localhost:3031/CustomerServicesgetchat")!
        components.queryItems = [
            .init(name: "PAN", value: pan),
            .init(name: "help_message_from_user", value: newMessage),
            .init(name: "help_request_id", value: help_request_id)
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
                    fetchMessages()
                }
            }
        }
        task.resume()
    }
}

struct ChatMessage: Identifiable, Decodable {
    let id = UUID()
    let first_name: String
    let last_name: String
    let created: String
    let message: String
    let request_id: Int
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(message.first_name) \(message.last_name)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                Spacer()
                Text(message.created)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Text(message.message)
                .font(.body)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
        .padding(.vertical, 2)
    }
}
