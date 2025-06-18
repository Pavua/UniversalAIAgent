import Foundation
import Combine

/// Сервис для работы с множественными LLM источниками
@MainActor
class MultiLLMService: ObservableObject {
    @Published var availableSources: [LLMSource] = []
    @Published var responses: [String: String] = [:]
    @Published var isLoading: Bool = false
    @Published var errors: [String: String] = [:]
    
    private let settingsModel: SettingsModel
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsModel: SettingsModel) {
        self.settingsModel = settingsModel
        loadAvailableSources()
    }
    
    /// Автодетект доступных LLM источников
    func loadAvailableSources() {
        availableSources.removeAll()
        
        // Проверка LM Studio
        checkLMStudio()
        
        // Проверка Docker контейнеров
        checkDockerContainers()
        
        // Добавление облачных источников
        addCloudSources()
    }
    
    private func checkLMStudio() {
        guard let url = URL(string: "http://localhost:1234/v1/models") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let source = LLMSource(
                        name: "LM Studio",
                        type: .lmstudio,
                        url: "http://localhost:1234",
                        isEnabled: true
                    )
                    self?.availableSources.append(source)
                }
            }
        }.resume()
    }
    
    private func checkDockerContainers() {
        let ports = [11434, 11435, 11436]
        let names = ["Docker Main", "Docker Test", "Docker Exp"]
        
        for (index, port) in ports.enumerated() {
            guard let url = URL(string: "http://localhost:\(port)/api/tags") else { continue }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        let source = LLMSource(
                            name: names[index],
                            type: .docker,
                            url: "http://localhost:\(port)",
                            isEnabled: true
                        )
                        self?.availableSources.append(source)
                    }
                }
            }.resume()
        }
    }
    
    private func addCloudSources() {
        if !settingsModel.openaiApiKey.isEmpty {
            let source = LLMSource(
                name: "OpenAI",
                type: .openai,
                url: "https://api.openai.com/v1",
                isEnabled: true
            )
            availableSources.append(source)
        }
    }
    
    /// Отправка запроса ко всем активным источникам параллельно
    func sendToAllSources(prompt: String) async {
        isLoading = true
        responses.removeAll()
        errors.removeAll()
        
        let enabledSources = availableSources.filter { $0.isEnabled }
        
        await withTaskGroup(of: Void.self) { group in
            for source in enabledSources {
                group.addTask { [weak self] in
                    await self?.sendToSource(source: source, prompt: prompt)
                }
            }
        }
        
        isLoading = false
    }
    
    private func sendToSource(source: LLMSource, prompt: String) async {
        do {
            let response = try await performRequest(source: source, prompt: prompt)
            await MainActor.run {
                responses[source.name] = response
            }
        } catch {
            await MainActor.run {
                errors[source.name] = error.localizedDescription
            }
        }
    }
    
    private func performRequest(source: LLMSource, prompt: String) async throws -> String {
        switch source.type {
        case .lmstudio, .openai:
            return try await performOpenAIStyleRequest(source: source, prompt: prompt)
        case .docker:
            return try await performOllamaRequest(source: source, prompt: prompt)
        case .mlx:
            return try await performMLXRequest(source: source, prompt: prompt)
        }
    }
    
    private func performOpenAIStyleRequest(source: LLMSource, prompt: String) async throws -> String {
        guard let url = URL(string: "\(source.url)/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if source.type == .openai {
            request.setValue("Bearer \(settingsModel.openaiApiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let body = [
            "model": source.type == .openai ? "gpt-4" : "llama3.2",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 1000,
            "temperature": 0.7
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let choices = response?["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw URLError(.cannotParseResponse)
    }
    
    private func performOllamaRequest(source: LLMSource, prompt: String) async throws -> String {
        guard let url = URL(string: "\(source.url)/api/generate") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "model": "llama3.2",
            "prompt": prompt,
            "stream": false
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let content = response?["response"] as? String {
            return content
        }
        
        throw URLError(.cannotParseResponse)
    }
    
    private func performMLXRequest(source: LLMSource, prompt: String) async throws -> String {
        // TODO: Реализовать MLX интеграцию
        return "MLX response: \(prompt)"
    }
    
    /// Получить лучший ответ на основе метрик
    func getBestResponse() -> (source: String, response: String)? {
        // Простая эвристика - самый длинный ответ без ошибок
        return responses.max { first, second in
            first.value.count < second.value.count
        }.map { (source: $0.key, response: $0.value) }
    }
}