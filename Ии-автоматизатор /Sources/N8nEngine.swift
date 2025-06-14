import Foundation

/// Движок n8n на основе локального CLI
final class N8nEngine: AutomationEngine {
    static let shared = N8nEngine()
    private var process: Process?
    private let binaryURL: URL = {
        // Путь к встроенному бинарнику n8n
        let bundleURL = Bundle.main.bundleURL
        return bundleURL.appendingPathComponent("Contents/Resources/n8n/n8n")
    }()

    func start() throws {
        guard process == nil else { return }
        let proc = Process()
        proc.executableURL = binaryURL
        proc.arguments = ["start", "--tunnel"]
        proc.standardOutput = FileHandle.standardOutput
        proc.standardError = FileHandle.standardError
        try proc.run()
        process = proc
    }

    func stop() throws {
        guard let proc = process else { return }
        proc.terminate()
        process = nil
    }

    func listWorkflows() async throws -> [N8nWorkflow] {
        return try await N8nService.shared.fetchWorkflows()
    }

    func trigger(workflowId: String, body: [String : Any]) async throws -> String {
        return try await N8nService.shared.triggerWebhook(workflowId: workflowId, body: body)
    }
} 