import Foundation

enum LMStudioError: Error { case invalidURL, badResponse }

final class LMStudioBridge {
    static let shared = LMStudioBridge()
    private init() {}

    /// Sends a chat completion request to LM Studio compatible server.
    /// - Parameters:
    ///   - prompt: user text
    ///   - onComplete: returns result string or error
    func generate(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let baseURL = LMStudioBridge.baseURL else {
            completion(.failure(LMStudioError.invalidURL)); return
        }
        let url = baseURL.appendingPathComponent("v1/chat/completions")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = [
            "model": "local-model",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 512,
            "temperature": 0.7,
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        let task = URLSession.shared.dataTask(with: req) { data, _, err in
            if let err = err { completion(.failure(err)); return }
            guard let data = data,
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = obj["choices"] as? [[String: Any]],
                  let content = (choices.first?["message"] as? [String: Any])?["content"] as? String
            else {
                completion(.failure(LMStudioError.badResponse)); return
            }
            completion(.success(content))
        }
        task.resume()
    }

    private static var baseURL: URL? {
        // check UserDefaults first
        if let saved = UserDefaults.standard.string(forKey: "LMSTUDIO_API_URL"), let url = URL(string: saved) {
            return url
        }
        // try environment variable
        if let env = ProcessInfo.processInfo.environment["LMSTUDIO_API_URL"], let url = URL(string: env) {
            return url
        }
        // fallback to localhost default
        return URL(string: "http://localhost:1234")
    }
}
