import Foundation

/// Represents a task imported from a JSON or YAML roadmap file
struct RoadmapTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?

    init(id: UUID = UUID(), title: String, description: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
    }
} 