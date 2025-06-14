import Foundation
import Combine

/// Manages loading and saving the list of projects using UserDefaults
final class ProjectStore: ObservableObject {
    @Published var projects: [Project] = [] {
        didSet { save() }
    }
    
    private let storageKey = "projects"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        load()
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            self.projects = decoded
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
} 