import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Просмотр истории чатов
struct HistoryView: View {
    @State private var searchText: String = ""
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.createdAt, order: .reverse) private var conversations: [Conversation]
    
    private var filteredConversations: [Conversation] {
        guard !searchText.isEmpty else { return conversations }
        return conversations.filter { conv in
            conv.messages.contains { msg in
                msg.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if searchText.isEmpty {
                    ForEach(filteredConversations) { conv in
                        NavigationLink(value: conv) {
                            Text(conv.createdAt, format: .dateTime)
                        }
                    }
                } else {
                    ForEach(HistorySearchService.shared.search(searchText), id: \\.messageID) { result in
                        Text(result.snippet)
                    }
                }
            }
            .searchable(text: $searchText, prompt: Text("Search messages"))
            .onAppear {
                // Полная реиндексация для поиска
                let allMessages = conversations.flatMap { $0.messages }
                try? HistorySearchService.shared.reindexAll(messages: allMessages)
            }
            .navigationTitle("History")
            .navigationDestination(for: Conversation.self) { conv in
                MessageListView(conversation: conv)
            }
        }
    }
}

/// Просмотр сообщений конкретного разговора
struct MessageListView: View {
    @Bindable var conversation: Conversation
    // Предварительное форматирование истории для экспорта
    private var exportContent: String {
        conversation.messages
            .sorted(by: { $0.timestamp < $1.timestamp })
            .map { msg in
                let who = msg.isUser ? "User" : "AI"
                let date = msg.timestamp.formatted(.dateTime)
                return "[\(date)] [\(who)]: \(msg.content)"
            }
            .joined(separator: "\n")
    }
    var body: some View {
        List(conversation.messages.sorted(by: { $0.timestamp < $1.timestamp })) { msg in
            HStack {
                if msg.isUser {
                    Spacer()
                    Text(msg.content)
                        .padding()
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Text(msg.content)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .navigationTitle(conversation.createdAt.formatted(.dateTime))
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: exportContent,
                          subject: Text("Chat History"),
                          message: Text("Conversation from \(conversation.createdAt.formatted(.dateTime))")) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: exportContent,
                          subject: Text("Chat History"),
                          message: Text("Conversation from \(conversation.createdAt.formatted(.dateTime))")) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
            #endif
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .modelContainer(for: [Conversation.self, Message.self])
    }
} 