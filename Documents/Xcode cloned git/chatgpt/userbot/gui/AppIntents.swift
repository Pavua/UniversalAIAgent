import AppIntents
import Foundation

// MARK: - Async Wrappers

extension PythonBridge {
    func sendAsync(_ command: PythonCommand) async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            send(command) { result in
                switch result {
                case let .success(json): cont.resume(returning: json)
                case let .failure(error): cont.resume(throwing: error)
                }
            }
        }
    }
}

extension OpenAIBridge {
    func generateAsync(prompt: String) async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            var output = ""
            generate(prompt: prompt, onToken: { token in
                output += token
            }, onComplete: { result in
                switch result {
                case .success: cont.resume(returning: output)
                case let .failure(error): cont.resume(throwing: error)
                }
            })
        }
    }
}

// MARK: - AppIntents

@available(macOS 14, *)
struct SendTelegramMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Telegram Message"

    @Parameter(title: "Chat ID") var chatId: Int
    @Parameter(title: "Message") var message: String

    func perform() async throws -> some ReturnsValue<String> {
        let response = try await PythonBridge.shared.sendAsync(.sendMessage(chatId: chatId, text: message))
        return .result(value: response)
    }
}

@available(macOS 14, *)
struct ChatWithAIIntent: AppIntent {
    static var title: LocalizedStringResource = "Chat with AI"

    @Parameter(title: "Prompt") var prompt: String

    func perform() async throws -> some ReturnsValue<String> {
        let result = try await OpenAIBridge.shared.generateAsync(prompt: prompt)
        return .result(value: result)
    }
}
