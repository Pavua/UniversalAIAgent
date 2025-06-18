import CoreML
import Foundation

enum LocalLLMError: Error { case modelNotFound, failedPrediction }

/// Very simplified inference wrapper.
/// Expects compiled `.mlmodelc` residing at `~/Models/LocalLM.mlmodelc` or path from `LOCAL_LLM_PATH` env.
final class LocalLLMService {
    static let shared = LocalLLMService()
    private var model: MLModel?

    private init() {
        load()
    }

    private func load() {
        if let path = ProcessInfo.processInfo.environment["LOCAL_LLM_PATH"], FileManager.default.fileExists(atPath: path) {
            model = try? MLModel(contentsOf: URL(fileURLWithPath: path))
            return
        }
        let defaultPath = NSString(string: "~/Models/LocalLM.mlmodelc").expandingTildeInPath
        if FileManager.default.fileExists(atPath: defaultPath) {
            model = try? MLModel(contentsOf: URL(fileURLWithPath: defaultPath))
        }
    }

    /// Dummy generate – for real model integrate token loop; here fallback to LMStudioBridge.
    func generate(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        if model == nil {
            // fallback to LMStudio
            LMStudioBridge.shared.generate(prompt: prompt, completion: completion)
            return
        }
        // Example for models that take {"prompt": string} input and returns {"text": string}
        guard let model else { completion(.failure(LocalLLMError.modelNotFound)); return }
        do {
            let out = try model.prediction(from: MLDictionaryFeatureProvider(dictionary: ["prompt": prompt]))
            if let txt = out.featureValue(for: "text")?.stringValue {
                completion(.success(txt))
            } else {
                completion(.failure(LocalLLMError.failedPrediction))
            }
        } catch {
            completion(.failure(error))
        }
    }
}
