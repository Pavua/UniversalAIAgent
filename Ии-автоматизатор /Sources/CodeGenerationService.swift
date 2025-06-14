import Foundation

/// Service for generating code via LLMs
final class CodeGenerationService {
    static let shared = CodeGenerationService()
    private init() {}

    /// Генерирует код для списка задач, стриминг токенов, можно передать шаблон
    func generateCode(tasks: [RoadmapTask], settings: SettingsStore, template: Template? = nil) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                let useLocal = settings.useLocalFirst && !settings.manualOverride
                for task in tasks {
                    var accumulated = ""
                    var continueAttempts = 0
                    let makePrompt: (Bool) -> String = { cont in
                        if cont {
                            return "continue"
                        }
                        if let tpl = template {
                            return "Use this template:\n\(tpl.content)\nGenerate Swift code for feature: \(task.title). Only output code blocks, prefix each file with '// File: <path>'"
                        } else {
                            return "Generate a Swift file for feature: \(task.title). Only output code blocks, prefix each file with '// File: <path>'"
                        }
                    }
                    var needContinue = true
                    while needContinue, continueAttempts < 3 {
                        let prompt = makePrompt(continueAttempts > 0)
                        let stream: AsyncThrowingStream<String, Error>
                        if useLocal, let modelPath = settings.selectedLocalModelPath {
                            stream = LLMService.shared.generateTokens(prompt: prompt, modelPath: modelPath)
                        } else {
                            stream = CloudLLMService.shared.generateTokens(prompt: prompt)
                        }
                        do {
                            for try await token in stream {
                                accumulated += token
                                continuation.yield(token)
                            }
                        } catch {
                            continuation.finish(throwing: error)
                            return
                        }
                        // Heuristic: if last 3 lines contain "// File:" assume generation still producing; else done.
                        let lastLines = accumulated.suffix(200)
                        if !lastLines.contains("// File:") || accumulated.hasSuffix("\n") {
                            needContinue = false
                        } else {
                            continueAttempts += 1
                        }
                    }
                    // mark task done for progress
                    continuation.yield("<<TASK_DONE>>")
                }
                continuation.finish()
            }
        }
    }
} 