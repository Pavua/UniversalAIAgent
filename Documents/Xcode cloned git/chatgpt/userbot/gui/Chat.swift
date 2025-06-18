import Foundation
import SwiftData

@Model
final class Chat: Identifiable {
    @Attribute(.unique) var id: Int
    var title: String
    @Relationship(deleteRule: .cascade, inverse: \Message.chat) var messages: [Message] = []

    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}
