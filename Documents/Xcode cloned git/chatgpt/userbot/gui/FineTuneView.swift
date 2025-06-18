import SwiftUI

struct FineTuneView: View {
    @State private var datasetPath: String = "~/dataset.jsonl"
    @State private var epochs: Int = 1
    @State private var batchSize: Int = 4
    @State private var learningRate: Double = 2e-5

    @State private var logs: String = ""
    @State private var isRunning = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroupBox("Dataset path") {
                TextField("/path/to/dataset.jsonl", text: $datasetPath)
            }

            HStack {
                Stepper("Epochs: \(epochs)", value: $epochs, in: 1 ... 10)
                Stepper("Batch: \(batchSize)", value: $batchSize, in: 1 ... 32)
            }

            HStack {
                Text("LR: ")
                Slider(value: $learningRate, in: 1e-6 ... 1e-4, step: 1e-6)
                Text(String(format: "%.1e", learningRate))
            }

            HStack {
                Button(isRunning ? "Cancel" : "Start") {
                    isRunning ? cancel() : start()
                }
                .disabled(isRunning == false && datasetPath.isEmpty)
            }

            Divider()

            Text("Logs")
            ScrollViewReader { proxy in
                ScrollView {
                    Text(logs)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id("BOTTOM")
                }
                .border(Color.gray)
                .onChange(of: logs) { _ in
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func start() {
        logs = ""
        isRunning = true
        FineTuneBridge.shared.start(datasetPath: NSString(string: datasetPath).expandingTildeInPath,
                                    epochs: epochs,
                                    batchSize: batchSize,
                                    learningRate: learningRate)
        { output in
            logs.append(output)
        } onComplete: { result in
            switch result {
            case .success: logs.append("\n✅ Completed\n")
            case let .failure(err): logs.append("\n❌ Error: \(err.localizedDescription)\n")
            }
            isRunning = false
        }
    }

    private func cancel() {
        FineTuneBridge.shared.cancel()
        isRunning = false
        logs.append("\n⛔️ Cancelled\n")
    }
}

#Preview { FineTuneView() }
