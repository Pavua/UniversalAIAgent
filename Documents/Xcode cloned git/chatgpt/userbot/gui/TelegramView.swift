import SwiftData
import SwiftUI

struct TelegramView: View {
    @Query(sort: \Chat.title) private var chats: [Chat]
    @Environment(\.modelContext) private var context
    @State private var isLoading = false
    @State private var selectedChat: Chat?
    @State private var searchText: String = ""

    var body: some View {
        NavigationSplitView {
            List(chats, selection: $selectedChat) { chat in
                NavigationLink(value: chat) {
                    Text(chat.title)
                }
            }
            .searchable(text: $searchText, prompt: "Search Chats")
            .listStyle(.sidebar)
            .refreshable { fetchChats() }
            .background(.ultraThinMaterial)
        } detail: {
            if let chat = selectedChat {
                TelegramChatView(chat: chat)
                    .toolbarRole(.editor)
            } else {
                Text("Select a chat")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Chats")
        .task { fetchChats() }
    }

    private func fetchChats() {
        guard !isLoading else { return }
        isLoading = true
        PythonBridge.shared.send(.getChats) { result in
            DispatchQueue.main.async {
                if case let .success(json) = result {
                    if let data = json.data(using: .utf8),
                       let dtos = try? JSONDecoder().decode([ChatDTO].self, from: data)
                    {
                        for chat in chats {
                            context.delete(chat)
                        }
                        dtos.forEach { dto in context.insert(Chat(id: dto.id, title: dto.title)) }
                    }
                }
                isLoading = false
            }
        }
    }
}

private struct ChatDTO: Codable { let id: Int; let title: String }

#Preview { TelegramView() }
