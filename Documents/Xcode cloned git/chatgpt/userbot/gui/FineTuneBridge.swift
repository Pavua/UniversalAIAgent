import Foundation

final class FineTuneBridge {
    static let shared = FineTuneBridge()
    private var process: Process?
    private var pipe: Pipe?

    /// Starts a fine-tune process with given parameters.
    func start(datasetPath: String,
               epochs: Int,
               batchSize: Int,
               learningRate: Double,
               onOutput: @escaping (String) -> Void,
               onComplete: @escaping (Result<Void, Error>) -> Void)
    {
        let exe = "/usr/bin/env"
        let module = "userbot.trainer"
        process = Process()
        pipe = Pipe()
        guard let process = process, let pipe = pipe else { return }
        process.executableURL = URL(fileURLWithPath: exe)
        process.arguments = ["python3", "-m", module,
                             "--dataset", datasetPath,
                             "--epochs", "\(epochs)",
                             "--batch-size", "\(batchSize)",
                             "--learning-rate", "\(learningRate)"]
        process.standardOutput = pipe
        process.standardError = pipe

        pipe.fileHandleForReading.readabilityHandler = { handle in
            if let str = String(data: handle.availableData, encoding: .utf8), !str.isEmpty {
                DispatchQueue.main.async { onOutput(str) }
            }
        }

        do {
            try process.run()
            process.terminationHandler = { proc in
                pipe.fileHandleForReading.readabilityHandler = nil
                if proc.terminationStatus == 0 {
                    DispatchQueue.main.async { onComplete(.success(())) }
                } else {
                    let err = NSError(domain: "FineTuneBridge", code: Int(proc.terminationStatus), userInfo: nil)
                    DispatchQueue.main.async { onComplete(.failure(err)) }
                }
            }
        } catch {
            onComplete(.failure(error))
        }
    }

    /// Stops the fine-tune process if running.
    func cancel() {
        process?.terminate()
    }
}
