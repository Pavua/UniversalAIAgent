import Foundation

/// Типы генерации структуры файлов
enum ScaffoldType: String, CaseIterable, Identifiable {
    case swiftUIView = "SwiftUI View"
    case viewModel = "ViewModel"
    case model = "Model"
    case service = "Service"
    case featureModule = "Feature Module"

    var id: String { rawValue }
}

/// Сервис для генерации файлов и директорий шаблонных модулей
final class ScaffoldingService {
    static let shared = ScaffoldingService()
    private init() {}

    /// Генерирует структуру файлов по имени и типу в указанной папке
    func generateScaffold(name: String, type: ScaffoldType, outputURL: URL) throws {
        let fm = FileManager.default
        switch type {
        case .swiftUIView:
            let fileName = "\(name)View.swift"
            let content = "import SwiftUI\n\nstruct \(name)View: View {\n    var body: some View {\n        Text(\"Hello from \(name)View!\")\n    }\n}\n"
            let fileURL = outputURL.appendingPathComponent(fileName)
            try fm.createDirectory(at: outputURL, withIntermediateDirectories: true)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        case .viewModel:
            let fileName = "\(name)ViewModel.swift"
            let content = "import Combine\n\nfinal class \(name)ViewModel: ObservableObject {\n    @Published var data: String = \"\"\n}\n"
            let fileURL = outputURL.appendingPathComponent(fileName)
            try fm.createDirectory(at: outputURL, withIntermediateDirectories: true)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        case .model:
            let fileName = "\(name).swift"
            let content = "import Foundation\n\nstruct \(name): Identifiable {\n    let id = UUID()\n}\n"
            let fileURL = outputURL.appendingPathComponent(fileName)
            try fm.createDirectory(at: outputURL, withIntermediateDirectories: true)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        case .service:
            let fileName = "\(name)Service.swift"
            let content = "import Foundation\n\nfinal class \(name)Service {\n    static let shared = \(name)Service()\n}\n"
            let fileURL = outputURL.appendingPathComponent(fileName)
            try fm.createDirectory(at: outputURL, withIntermediateDirectories: true)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        case .featureModule:
            // Create folder for module
            let moduleURL = outputURL.appendingPathComponent(name)
            try fm.createDirectory(at: moduleURL, withIntermediateDirectories: true)
            // Generate default files
            try generateScaffold(name: name, type: .swiftUIView, outputURL: moduleURL)
            try generateScaffold(name: name, type: .viewModel, outputURL: moduleURL)
            try generateScaffold(name: name, type: .model, outputURL: moduleURL)
            try generateScaffold(name: name, type: .service, outputURL: moduleURL)
        }
    }
} 