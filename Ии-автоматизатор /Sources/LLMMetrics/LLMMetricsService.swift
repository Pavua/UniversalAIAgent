import Foundation

/// Метрика генерации: количество токенов и общее время в секундах
struct LLMMetrics {
    let modelPath: String
    let tokensCount: Int
    let duration: TimeInterval
}

/// Сервис для сбора метрик по генерации токенов
final class LLMMetricsService {
    static let shared = LLMMetricsService()
    private init() {}

    /// Запустить сбор метрик для генерации prompt
    func measure(prompt: String, modelPath: String) async throws -> LLMMetrics {
        let start = Date()
        var count = 0
        for try await _ in LLMService.shared.generateTokens(prompt: prompt, modelPath: modelPath) {
            count += 1
        }
        let duration = Date().timeIntervalSince(start)
        return LLMMetrics(modelPath: modelPath, tokensCount: count, duration: duration)
    }
} 