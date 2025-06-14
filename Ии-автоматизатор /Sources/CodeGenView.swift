import SwiftUI
import SwiftData
import AppKit

struct CodeGenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Template.name, animation: .default) private var templates: [Template]
    @State private var selectedTemplateId: UUID? = nil
    @EnvironmentObject var settingsStore: SettingsStore
    let tasks: [RoadmapTask]
    @State private var selectedTasks: Set<UUID> = []
    @State private var log: String = ""
    @State private var isRunning: Bool = false
    @State private var streamTask: Task<Void, Error>? = nil
    @State private var outputFolder: URL? = nil
    @State private var showAlert: Bool = false
    @State private var alertText: String = ""
    @State private var tasksCompleted: Int = 0
    private var totalTasks: Int { selectedTasks.count }
    private var progress: Double { totalTasks == 0 ? 0 : Double(tasksCompleted) / Double(totalTasks) }

    var body: some View {
        VStack {
            // Template Picker
            HStack {
                Text("Template:")
                Picker("Template", selection: $selectedTemplateId) {
                    Text("None").tag(UUID?.none)
                    ForEach(templates) { tpl in
                        Text(tpl.name).tag(Optional(tpl.id))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                Spacer()
            }
            HStack {
                Button("Select Output Folder") {
                    let panel = NSOpenPanel()
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false
                    panel.allowsMultipleSelection = false
                    if panel.runModal() == .OK {
                        outputFolder = panel.url
                    }
                }
                if let folder = outputFolder {
                    Text(folder.lastPathComponent)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                Spacer()
                Button(isRunning ? "Cancel" : "Generate Code") {
                    if isRunning {
                        streamTask?.cancel()
                        isRunning = false
                    } else {
                        runGeneration()
                    }
                }
                .disabled(selectedTasks.isEmpty || outputFolder == nil)
            }
            .padding([.leading, .trailing])
            Divider()
            HStack {
                VStack {
                    Text("Roadmap Tasks").font(.headline)
                    List(tasks, id: \.id, selection: $selectedTasks) { task in
                        Text(task.title)
                    }
                    .frame(minWidth: 200)
                    .padding([.bottom])
                }
                Divider()
                ScrollView {
                    Text(log)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            if isRunning {
                ProgressView(value: progress)
                    .padding([.leading, .trailing])
            }
        }
        .padding()
        .alert("Export Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertText)
        }
    }

    private func runGeneration() {
        isRunning = true
        log = ""
        tasksCompleted = 0
        streamTask?.cancel()
        let selected = tasks.filter { selectedTasks.contains($0.id) }
        let tpl = templates.first(where: { $0.id == selectedTemplateId })
        streamTask = Task { @MainActor in
            for try await token in CodeGenerationService.shared.generateCode(tasks: selected, settings: settingsStore, template: tpl) {
                if token == "<<TASK_DONE>>" {
                    tasksCompleted += 1
                    continue
                }
                log += token
            }
            isRunning = false
            // После завершения экспортируем файлы
            do {
                try exportFiles(from: log)
            } catch {
                alertText = error.localizedDescription
                showAlert = true
            }
        }
    }

    /// Парсит `// File: path` секции в логе и записывает файлы в outputFolder
    private func exportFiles(from log: String) throws {
        guard let folder = outputFolder else { return }
        let lines = log.components(separatedBy: "\n")
        var currentPath: String?
        var buffer = ""
        for line in lines {
            if line.starts(with: "// File: ") {
                // Сохраняем предыдущий файл
                if let path = currentPath {
                    let url = folder.appendingPathComponent(path)
                    let dir = url.deletingLastPathComponent()
                    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                    try buffer.write(to: url, atomically: true, encoding: .utf8)
                    buffer = ""
                }
                currentPath = String(line.dropFirst("// File: ".count))
            } else {
                buffer += line + "\n"
            }
        }
        // Сохраняем последний файл
        if let path = currentPath {
            let url = folder.appendingPathComponent(path)
            let dir = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try buffer.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

struct CodeGenView_Previews: PreviewProvider {
    static var previews: some View {
        CodeGenView(tasks: [
            RoadmapTask(title: "Feature A"),
            RoadmapTask(title: "Feature B")
        ])
        .environmentObject(SettingsStore())
    }
} 