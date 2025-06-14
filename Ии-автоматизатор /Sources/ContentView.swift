import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif
import Yams

struct ContentView: View {
    @EnvironmentObject var projectStore: ProjectStore
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var modelStore: ModelStore
    @State private var roadmapTasks: [RoadmapTask] = []
    @State private var isTargeted: Bool = false
    #if os(iOS)
    @State private var showFileImporter: Bool = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    var body: some View {
        TabView {
            ScaffoldView()
                .tabItem {
                    Label("Scaffold", systemImage: "folder.badge.plus")
                }
            NavigationView {
                List {
                    // Import Roadmap Drop Area
                    Section(header: Text("Import Roadmap").font(.headline)) {
                        VStack {
                            Text(roadmapTasks.isEmpty ? "Drop JSON/YAML file here" : "Imported Tasks")
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(isTargeted ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                                .onDrop(of: [UTType.json.identifier, UTType.yaml.identifier, UTType.plainText.identifier], isTargeted: $isTargeted) { providers in
                                    handleDrop(providers: providers)
                                }
                            if !roadmapTasks.isEmpty {
                                ForEach(roadmapTasks) { task in
                                    VStack(alignment: .leading) {
                                        Text(task.title).font(.subheadline)
                                        if let desc = task.description {
                                            Text(desc).font(.caption).foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    Text("Local Models")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    // Local Models Section
                    Section(header: Text("Local Models").font(.headline)) {
                        if modelStore.localModels.isEmpty {
                            Text("No local models found.")
                        } else {
                            ForEach(modelStore.localModels) { model in
                                HStack {
                                    Text(model.name)
                                    Spacer()
                                    if settingsStore.selectedLocalModelPath == model.path {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    settingsStore.selectedLocalModelPath = model.path
                                }
                            }
                        }
                    }
                    .onAppear {
                        modelStore.fetchModels()
                    }
                    
                    Text("Projects")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    // Placeholder for project cards
                    ForEach(projectStore.projects) { project in
                        ProjectCardView(projectName: project.name, templateName: project.template)
                    }
                    .onDelete { offsets in
                        projectStore.projects.remove(atOffsets: offsets)
                    }
                }
                #if os(iOS)
                .listStyle(horizontalSizeClass == .regular ? SidebarListStyle() : InsetGroupedListStyle())
                #else
                .listStyle(SidebarListStyle())
                #endif
                
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            projectStore.projects.append(Project(name: "New Project", template: ""))
                        }) {
                            Label("Add Project", systemImage: "plus")
                        }
                    }
                    #if os(macOS)
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            let panel = NSOpenPanel()
                            panel.allowedContentTypes = [.json, .yaml, .plainText]
                            panel.canChooseDirectories = false
                            panel.allowsMultipleSelection = false
                            panel.begin { response in
                                if response == .OK, let url = panel.url, let data = try? Data(contentsOf: url) {
                                    let ext = url.pathExtension.lowercased()
                                    let type: String
                                    switch ext {
                                    case "json": type = UTType.json.identifier
                                    case "yaml", "yml": type = UTType.yaml.identifier
                                    default: type = UTType.plainText.identifier
                                    }
                                    DispatchQueue.main.async {
                                        parseRoadmap(data: data, type: type)
                                    }
                                }
                            }
                        }) {
                            Label("Import File", systemImage: "doc")
                        }
                    }
                    #endif
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showFileImporter = true }) {
                            Label("Import File", systemImage: "doc")
                        }
                    }
                    #endif
                }
            }
            #if os(iOS)
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: [UTType.json, UTType.yaml, UTType.plainText],
                          allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first, let data = try? Data(contentsOf: url) {
                        let ext = url.pathExtension.lowercased()
                        let type: String
                        switch ext {
                        case "json": type = UTType.json.identifier
                        case "yaml", "yml": type = UTType.yaml.identifier
                        default: type = UTType.plainText.identifier
                        }
                        DispatchQueue.main.async {
                            parseRoadmap(data: data, type: type)
                        }
                    }
                case .failure(let error):
                    print("File import error: \(error)")
                }
            }
            #endif
            .tabItem {
                Label("Chat", systemImage: "bubble.left.and.bubble.right")
            }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            CodeGenView(tasks: roadmapTasks)
                .environmentObject(settingsStore)
                .tabItem {
                    Label("CodeGen", systemImage: "hammer")
                }
            AutomationView()
                .tabItem {
                    Label("Automation", systemImage: "gearshape.2")
                }
        }
    }

    // MARK: - Import Roadmap Handlers
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let item = providers.first else { return false }
        let types = [UTType.json.identifier, UTType.yaml.identifier, UTType.plainText.identifier]
        for type in types {
            if item.hasItemConformingToTypeIdentifier(type) {
                item.loadDataRepresentation(forTypeIdentifier: type) { data, error in
                    guard let data = data else { return }
                    DispatchQueue.main.async {
                        parseRoadmap(data: data, type: type)
                    }
                }
                return true
            }
        }
        return false
    }

    private func parseRoadmap(data: Data, type: String) {
        do {
            if type == UTType.json.identifier {
                let decoded = try JSONDecoder().decode([RoadmapTask].self, from: data)
                roadmapTasks = decoded
            } else if type == UTType.plainText.identifier {
                let text = String(decoding: data, as: UTF8.self)
                let lines = text.split(separator: "\n").map { String($0) }
                roadmapTasks = lines.map { RoadmapTask(title: $0) }
            } else {
                let yamlString = String(decoding: data, as: UTF8.self)
                let decoded: [RoadmapTask] = try YAMLDecoder().decode([RoadmapTask].self, from: yamlString)
                roadmapTasks = decoded
            }
        } catch {
            print("Error parsing roadmap: \(error)")
        }
    }
}

struct ProjectCardView: View {
    var projectName: String
    var templateName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(projectName)
                .font(.headline)
            Text("Template: \(templateName)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock stores for preview
        let projectStore = ProjectStore()
        projectStore.projects = [
            Project(name: "Demo Project", template: "Template A")
        ]
        let settingsStore = SettingsStore()
        settingsStore.selectedLocalModelPath = "/path/to/model.gguf"
        let modelStore = ModelStore()
        modelStore.localModels = [
            LocalModel(name: "DemoModel", path: "/path/to/model.gguf")
        ]
        return ContentView()
            .environmentObject(projectStore)
            .environmentObject(settingsStore)
            .environmentObject(modelStore)
    }
} 