import Foundation
import llama
// import Transformers (MLX integration deferred)

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Service for running local LLM models using llama.swift
final class LLMService {
    static let shared = LLMService()
    private var runnerCache: [String: LlamaRunner] = [:]

    /// Get or load a LlamaRunner for the given model path
    func runner(forModelPath path: String) async throws -> LlamaRunner {
        if let cached = runnerCache[path] {
            return cached
        }
        let url = URL(fileURLWithPath: path)
        let ext = url.pathExtension.lowercased()
        if ext == "mlx" {
            print("⚡️ Loading MLX model at \(path)")
        }
        let runner = LlamaRunner(modelURL: url)
        runnerCache[path] = runner
        return runner
    }

    /// Generate tokens asynchronously for a given prompt and model
    func generateTokens(prompt: String, modelPath: String) -> AsyncThrowingStream<String, Error> {
        // On-device LLM via Apple FoundationModels
#if canImport(FoundationModels)
        if UserDefaults.standard.bool(forKey: "useFoundationModels") {
            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        if #available(macOS 14.0, iOS 17.0, watchOS 9.0, *) {
                            let fmModel = TextGenerationModel(.default)
                            for try await token in fmModel.generate(prompt: prompt) {
                                continuation.yield(token)
                            }
                            continuation.finish()
                        } else {
                            continuation.finish(throwing: NSError(domain: "LLMService", code: -1, userInfo: [NSLocalizedDescriptionKey: "FoundationModels not supported on this OS version"]))
                        }
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
#endif
        // Local LLM via llama.swift
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let runner = try await runner(forModelPath: modelPath)
                    // Use maximum available processor threads for inference
                    let threadCount = UInt(ProcessInfo.processInfo.activeProcessorCount)
                    let config = LlamaRunner.Config(numThreads: threadCount, numTokens: 512)
                    for try await token in runner.run(with: prompt, config: config) {
                        continuation.yield(token)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
} 