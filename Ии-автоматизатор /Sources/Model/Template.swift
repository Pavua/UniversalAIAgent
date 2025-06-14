import Foundation
import SwiftData

/// Represents a code generation template stored as JSON
@Model
final class Template: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var content: String

    init(id: UUID = UUID(), name: String, content: String) {
        self.id = id
        self.name = name
        self.content = content
    }
} 