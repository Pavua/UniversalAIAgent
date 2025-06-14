import PackagePlugin
import Foundation

@main
struct ScaffoldPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let name = arguments.first ?? "FeatureModule"
        let fm = FileManager.default
        let moduleDir = cwd.appendingPathComponent(name)
        try fm.createDirectory(at: moduleDir, withIntermediateDirectories: true)
        let viewFile = moduleDir.appendingPathComponent("\(name)View.swift")
        let viewContent = """
        import SwiftUI

        struct \(name)View: View {
            @ObservedObject var viewModel: \(name)ViewModel

            var body: some View {
                VStack {
                    Text("Welcome to \(name)View")
                    // TODO: Add UI components
                }
            }
        }
        """
        try viewContent.write(to: viewFile, atomically: true, encoding: .utf8)

        let viewModelFile = moduleDir.appendingPathComponent("\(name)ViewModel.swift")
        let viewModelContent = """
        import Combine

        final class \(name)ViewModel: ObservableObject {
            @Published var data: String = ""
            
            // TODO: Add business logic here
        }
        """
        try viewModelContent.write(to: viewModelFile, atomically: true, encoding: .utf8)

        print("Scaffolded module \(name) with View and ViewModel at \(moduleDir.path)")
    }
} 