import Foundation

/// Bridge for OpenAI Chat Completions with streaming (SSE).
final class OpenAIBridge: NSObject, URLSessionDataDelegate {
    static let shared = OpenAIBridge()
    private var session: URLSession!
    private var task: URLSessionDataTask?
    private var buffer = ""
    private var onToken: ((String) -> Void)?
    private var onComplete: ((Result<Void, Error>) -> Void)?

    override private init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }

    /// Starts streaming generation from OpenAI API.
    /// - Parameters:
    ///   - prompt: user text
    ///   - model: OpenAI model (default: gpt-3.5-turbo)
    ///   - temperature: sampling temperature
    ///   - onToken: called for each token chunk
    ///   - onComplete: called when stream ends or on error
    func generate(prompt: String,
                  model: String = "gpt-3.5-turbo",
                  temperature: Double = 0.7,
                  onToken: @escaping (String) -> Void,
                  onComplete: @escaping (Result<Void, Error>) -> Void)
    {
        guard let apiKey = UserDefaults.standard.string(forKey: "OPENAI_API_KEY"), !apiKey.isEmpty else {
            onComplete(.failure(NSError(domain: "OpenAIBridge", code: 1,
                                        userInfo: [NSLocalizedDescriptionKey: "Missing OpenAI API Key"])))
            return
        }
        self.onToken = onToken
        self.onComplete = onComplete
        buffer = ""
        var req = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": model,
            "messages": [["role": "user", "content": prompt]],
            "stream": true,
            "temperature": temperature,
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        task = session.dataTask(with: req)
        task?.resume()
    }

    /// Cancels ongoing stream.
    func cancel() {
        task?.cancel()
        task = nil
        onComplete?(.failure(NSError(domain: "OpenAIBridge", code: -1,
                                     userInfo: [NSLocalizedDescriptionKey: "Cancelled"])))
    }

    // MARK: URLSessionDataDelegate

    func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive data: Data) {
        guard let chunk = String(data: data, encoding: .utf8) else { return }
        buffer += chunk
        let parts = buffer.components(separatedBy: "\n\n")
        // Process each complete event
        for i in 0 ..< parts.count - 1 {
            let part = parts[i]
            for line in part.components(separatedBy: "\n") {
                guard line.hasPrefix("data:") else { continue }
                let dataStr = line.replacingOccurrences(of: "data:", with: "").trimmingCharacters(in: .whitespaces)
                if dataStr == "[DONE]" {
                    onComplete?(.success(()))
                    continue
                }
                if let jsonData = dataStr.data(using: .utf8),
                   let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                   let choices = obj["choices"] as? [[String: Any]],
                   let delta = choices.first?["delta"] as? [String: Any],
                   let content = delta["content"] as? String
                {
                    onToken?(content)
                }
            }
        }
        // Keep last incomplete part
        buffer = parts.last ?? ""
    }

    func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            onComplete?(.failure(error))
        } else {
            onComplete?(.success(()))
        }
    }
}
