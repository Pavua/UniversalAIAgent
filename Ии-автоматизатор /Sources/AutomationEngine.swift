import Foundation

/// Протокол для абстрагирования движка автоматизации
protocol AutomationEngine {
    /// Получить список доступных рабочих процессов
    func listWorkflows() async throws -> [N8nWorkflow]
    /// Запустить рабочий процесс с указанным ID и телом запроса
    func trigger(workflowId: String, body: [String: Any]) async throws -> String
    /// Запустить движок
    func start() throws
    /// Остановить движок
    func stop() throws
} 