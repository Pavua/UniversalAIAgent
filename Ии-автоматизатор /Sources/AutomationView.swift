import SwiftUI
import SwiftData

struct AutomationView: View {
    @State private var workflows: [N8nWorkflow] = []
    @State private var selectedWorkflowId: String? = nil
    @State private var inputJSON: String = "{}"
    @State private var outputText: String = ""
    @State private var isRunning: Bool = false
    @State private var showError: Bool = false
    @State private var errorMsg: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Automation Workflows").font(.title2).bold()
            HStack {
                Button("Load Workflows") {
                    Task {
                        do {
                            workflows = try await N8nService.shared.fetchWorkflows()
                        } catch {
                            showError = true
                            errorMsg = error.localizedDescription
                        }
                    }
                }
                Spacer()
            }
            Picker("Workflow", selection: $selectedWorkflowId) {
                Text("Select").tag(String?.none)
                ForEach(workflows) { wf in
                    Text(wf.name).tag(Optional(wf.id))
                }
            }
            .pickerStyle(MenuPickerStyle())
            TextEditor(text: $inputJSON)
                .font(.system(.body, design: .monospaced))
                .border(Color.secondary)
                .frame(height: 100)
            HStack {
                Button(isRunning ? "Cancel" : "Run Workflow") {
                    if isRunning {
                        // cancellation not implemented
                        isRunning = false
                    } else {
                        runWorkflow()
                    }
                }
                .disabled(selectedWorkflowId == nil)
                if isRunning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.leading)
                }
                Spacer()
            }
            ScrollView {
                Text(outputText)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            Spacer()
        }
        .padding()
        .alert("Automation Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMsg)
        }
    }

    private func runWorkflow() {
        guard let wfId = selectedWorkflowId, let data = inputJSON.data(using: .utf8) else { return }
        isRunning = true
        Task {
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                let result = try await N8nService.shared.triggerWebhook(workflowId: wfId, body: json)
                await MainActor.run {
                    outputText = result
                    isRunning = false
                }
            } catch {
                await MainActor.run {
                    errorMsg = error.localizedDescription
                    showError = true
                    isRunning = false
                }
            }
        }
    }
}

struct AutomationView_Previews: PreviewProvider {
    static var previews: some View {
        AutomationView()
    }
} 