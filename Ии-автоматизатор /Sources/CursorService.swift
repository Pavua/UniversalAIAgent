import Foundation

/// Сервис для генерации кода с помощью Cursor CLI
final class CursorService {
    static let shared = CursorService()
    private init() {}

    /// Сгенерировать код по текстовому промпту через cursor CLI
    func generateCode(prompt: String) async throws -> String {
        let process = Process()
        let executablePath = "/usr/local/bin/cursor" // путь к Cursor CLI
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = ["generate", "--prompt", prompt]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "CursorService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode Cursor output"])
        }
        return output
    }
} 