import Combine
import Foundation

/// Represents a local LLM model available for inference
struct LocalModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let path: String

    init(id: UUID = UUID(), name: String, path: String) {
        self.id = id
        self.name = name
        self.path = path
    }
}

/// Manages fetching local LLM models from LM Studio and fallback scanning
final class ModelStore: ObservableObject {
    @Published var localModels: [LocalModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    /// Fetch model list from LM Studio API or fallback to default folder
    func fetchModels() {
        // Try LM Studio API
        guard let url = URL(string: "http://127.0.0.1:1234/v1/models") else {
            scanDefaultFolder()
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> [LocalModel] in
                // LM Studio returns {"data":[{id,name,}]}
                struct Response: Codable { let data: [LocalModel] }
                if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
                    return decoded.data
                } else {
                    return try JSONDecoder().decode([LocalModel].self, from: data)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.scanDefaultFolder()
                }
            }, receiveValue: { [weak self] models in
                if models.isEmpty {
                    self?.scanDefaultFolder()
                } else {
                    self?.localModels = models
                }
            })
            .store(in: &cancellables)
    }
    
    /// Fallback scanning of LM Studio models in common folders
    private func scanDefaultFolder() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let folders = [
            home.appendingPathComponent("LM Studio/models"),
            home.appendingPathComponent("Library/Application Support/LM Studio/models")
        ]
        var models: [LocalModel] = []
        for folder in folders {
            if let urls = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                for url in urls where ["gguf", "mlx"].contains(url.pathExtension.lowercased()) {
                    let name = url.deletingPathExtension().lastPathComponent
                    let model = LocalModel(name: name, path: url.path)
                    if !models.contains(where: { $0.path == model.path }) {
                        models.append(model)
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.localModels = models
        }
    }
} 