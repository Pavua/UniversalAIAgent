import Foundation
import SwiftData

@Model
final class Message: Identifiable {
    @Attribute(.unique) var id: Int
    var text: String
    var date: Date
    @Relationship var chat: Chat?

    init(id: Int, text: String, date: Date = .now, chat: Chat?) {
        self.id = id
        self.text = text
        self.date = date
        self.chat = chat
    }
}
