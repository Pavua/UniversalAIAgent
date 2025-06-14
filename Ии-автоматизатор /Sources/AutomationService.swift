import Foundation

/// Represents an n8n workflow
struct N8nWorkflow: Identifiable, Codable {
    let id: String
    let name: String
}

/// Service for interacting with local n8n instance via REST API and webhooks
final class N8nService {
    static let shared = N8nService()
    /// Base URL for n8n, configurable via Settings
    private var baseURL: URL {
        let str = UserDefaults.standard.string(forKey: "n8nBaseURL") ?? "http://127.0.0.1:5678"
        return URL(string: str)!
    }

    /// Fetches available workflows from n8n
    func fetchWorkflows() async throws -> [N8nWorkflow] {
        let url = baseURL.appendingPathComponent("rest/workflows")
        var request = URLRequest(url: url)
        // Authorization header if needed
        if let apiKey = UserDefaults.standard.string(forKey: "n8nApiKey"), !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([N8nWorkflow].self, from: data)
    }

    /// Triggers a webhook for the given workflow ID with JSON body; returns raw response text
    func triggerWebhook(workflowId: String, body: [String: Any]) async throws -> String {
        let url = baseURL.appendingPathComponent("webhook/")
            .appendingPathComponent(workflowId)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Authorization header if needed
        if let apiKey = UserDefaults.standard.string(forKey: "n8nApiKey"), !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return String(decoding: data, as: UTF8.self)
    }
} 