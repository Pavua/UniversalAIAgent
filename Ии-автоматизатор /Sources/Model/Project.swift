import Foundation

/// Represents a single project with a name and associated template
struct Project: Identifiable, Codable {
    let id: UUID
    var name: String
    var template: String
    
    init(id: UUID = UUID(), name: String, template: String) {
        self.id = id
        self.name = name
        self.template = template
    }
} 