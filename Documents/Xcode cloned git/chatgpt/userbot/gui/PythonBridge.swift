import Foundation

enum PythonCommand {
    case getChats
    case getMessages(chatId: Int)
    case sendMessage(chatId: Int, text: String)
    case updateConfig(values: [String: Any])
    case sendFile(chatId: Int, filePath: String)

    var json: String {
        switch self {
        case .getChats:
            return "{\"cmd\":\"get_chats\"}"
        case let .getMessages(id):
            return "{\"cmd\":\"get_messages\",\"chat_id\":\(id)}"
        case let .sendMessage(id, text):
            let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"")
            return "{\"cmd\":\"send_message\",\"chat_id\":\(id),\"text\":\"\(escapedText)\"}"
        case let .updateConfig(dict):
            if let data = try? JSONSerialization.data(withJSONObject: dict),
               let jsonStr = String(data: data, encoding: .utf8)
            {
                return "{\"cmd\":\"update_config\",\"values\":\(jsonStr)}"
            } else {
                return "{\"cmd\":\"update_config\"}"
            }
        case let .sendFile(id, filePath):
            let escapedPath = filePath.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
            return "{\"cmd\":\"send_file\",\"chat_id\":\(id),\"file_path\":\"\(escapedPath)\"}"
        }
    }
}

final class PythonBridge {
    static let shared = PythonBridge()
    private var process: Process?
    private var stdinPipe: Pipe?
    private var stdoutPipe: Pipe?

    typealias Completion = (Result<String, Error>) -> Void

    func send(_ command: PythonCommand, completion: @escaping Completion) {
        ensureProcess()
        guard let stdinPipe else {
            completion(.failure(NSError(domain: "PythonBridge", code: 1, userInfo: [NSLocalizedDescriptionKey: "stdin not ready"])))
            return
        }
        let jsonLine = command.json + "\n"
        if let data = jsonLine.data(using: .utf8) {
            stdinPipe.fileHandleForWriting.write(data)
        }
        pendingCallbacks.append(completion)
    }

    private var pendingCallbacks: [Completion] = []

    private func ensureProcess() {
        if process != nil { return }
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = ["python3", "-m", "userbot"]

        let stdin = Pipe()
        let stdout = Pipe()
        proc.standardInput = stdin
        proc.standardOutput = stdout
        proc.standardError = Pipe()

        stdout.fileHandleForReading.readabilityHandler = { [weak self] handle in
            guard let self else { return }
            if let line = String(data: handle.availableData, encoding: .utf8), !line.isEmpty {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                DispatchQueue.main.async {
                    if self.pendingCallbacks.isEmpty { return }
                    let cb = self.pendingCallbacks.removeFirst()
                    cb(.success(trimmed))
                }
            }
        }
        do {
            try proc.run()
            process = proc
            stdinPipe = stdin
            stdoutPipe = stdout
        } catch {
            print("PythonBridge failed to start: \(error)")
        }
    }
}
