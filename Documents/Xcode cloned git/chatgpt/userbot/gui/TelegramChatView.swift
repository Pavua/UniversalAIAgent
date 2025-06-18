import SwiftUI
import UniformTypeIdentifiers

struct TelegramChatView: View {
    let chat: Chat
    @State private var showFileImporter = false
    @State private var messages: [MessageDTO] = []
    @State private var newText: String = ""
    @State private var isLoading = false

    var body: some View {
        VStack {
            List(messages, id: \._id) { msg in
                HStack(alignment: .top) {
                    if let imageURL = URL(string: msg.text),
                       ["png", "jpg", "jpeg", "gif"].contains(imageURL.pathExtension.lowercased())
                    {
                        AsyncImage(url: imageURL) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFit().frame(maxWidth: 200, maxHeight: 200)
                            } else if phase.error != nil {
                                Text("Image load error").foregroundColor(.red)
                            } else {
                                ProgressView()
                            }
                        }
                    } else {
                        Text(msg.text)
                    }
                    Spacer()
                    Text(msg.dateTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            HStack {
                TextField("Message", text: $newText)
                Button("Send") { sendMessage() }
                    .disabled(newText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(chat.title)
        .task { fetchMessages() }
        .toolbar {
            HStack(spacing: 16) {
                Button(action: fetchMessages) { Image(systemName: "arrow.clockwise") }
                Button(action: { showFileImporter = true }) { Image(systemName: "paperclip") }
            }
        }
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.item], allowsMultipleSelection: false)
        { result in
            switch result {
            case let .success(urls):
                if let url = urls.first {
                    sendFile(url)
                }
            case let .failure(err):
                print("File import error: \(err)")
            }
        }
    }

    private func fetchMessages() {
        guard !isLoading else { return }
        isLoading = true
        PythonBridge.shared.send(.getMessages(chatId: chat.id)) { result in
            DispatchQueue.main.async {
                if case let .success(json) = result,
                   let data = json.data(using: .utf8),
                   let dtos = try? JSONDecoder().decode([MessageDTO].self, from: data)
                {
                    self.messages = dtos
                }
                isLoading = false
            }
        }
    }

    private func sendMessage() {
        let text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        newText = ""
        PythonBridge.shared.send(.sendMessage(chatId: chat.id, text: text)) { _ in
            fetchMessages()
        }
    }

    private func sendFile(_ url: URL) {
        PythonBridge.shared.send(.sendFile(chatId: chat.id, filePath: url.path)) { _ in
            fetchMessages()
        }
    }
}

private struct MessageDTO: Codable {
    let id: Int
    let text: String
    let date: String

    var dateTime: Date {
        ISO8601DateFormatter().date(from: date) ?? .now
    }

    var _id: Int { id }
}

#Preview {
    NavigationStack {
        TelegramChatView(chat: Chat(id: 1, title: "Preview"))
    }
}
