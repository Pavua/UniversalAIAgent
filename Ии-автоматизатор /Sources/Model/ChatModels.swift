import Foundation
import SwiftData

/// Conversation с историями сообщений
@Model
final class Conversation: Identifiable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var messages: [Message]

    init(id: UUID = UUID(), createdAt: Date = Date(), messages: [Message] = []) {
        self.id = id
        self.createdAt = createdAt
        self.messages = messages
    }
}

/// Сообщение в разговоре
@Model
final class Message: Identifiable {
    @Attribute(.unique) var id: UUID
    var content: String
    var isUser: Bool
    var timestamp: Date

    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
} 