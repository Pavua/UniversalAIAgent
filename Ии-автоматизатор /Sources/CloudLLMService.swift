import Foundation

/// Service for interacting with OpenAI SSE endpoint
typealias JSON = [String: Any]

final class CloudLLMService {
    static let shared = CloudLLMService()
    private init() {}

    func generateTokens(prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            guard let apiKey = KeychainService.shared.getAPIKey(), !apiKey.isEmpty else {
                continuation.finish(throwing: NSError(domain: "CloudLLMService", code: 1, userInfo: [NSLocalizedDescriptionKey: "OpenAI API key not found"]))
                return
            }
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                continuation.finish(throwing: URLError(.badURL))
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: JSON = [
                "model": "gpt-3.5-turbo",
                "messages": [["role": "user", "content": prompt]],
                "stream": true
            ]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                continuation.finish(throwing: error)
                return
            }

            Task {
                do {
                    let (bytes, _) = try await URLSession.shared.bytes(for: request)
                    var buffer = Data()
                    for try await byte in bytes {
                        if byte == UInt8(ascii: "\n") {
                            if !buffer.isEmpty, let line = String(data: buffer, encoding: .utf8) {
                                buffer.removeAll()
                                if line.starts(with: "data: ") {
                                    let jsonString = String(line.dropFirst(6))
                                    if jsonString == "[DONE]" {
                                        continuation.finish()
                                        return
                                    }
                                    if let data = jsonString.data(using: .utf8),
                                       let object = try JSONSerialization.jsonObject(with: data) as? JSON,
                                       let choices = object["choices"] as? [JSON],
                                       let delta = choices.first?["delta"] as? JSON,
                                       let content = delta["content"] as? String {
                                        continuation.yield(content)
                                    }
                                }
                            }
                        } else {
                            buffer.append(byte)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
} 