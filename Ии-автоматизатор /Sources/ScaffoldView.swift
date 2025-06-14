import SwiftUI
import AppKit

struct ScaffoldView: View {
    @State private var moduleName: String = ""
    @State private var selectedType: ScaffoldType = .featureModule
    @State private var outputFolder: URL? = nil
    @State private var showAlert: Bool = false
    @State private var alertText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scaffold Generator").font(.title2).bold()
            TextField("Module Name", text: $moduleName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Picker("Type", selection: $selectedType) {
                ForEach(ScaffoldType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
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
            }
            HStack {
                Button("Generate Scaffold") {
                    guard !moduleName.isEmpty, let folder = outputFolder else { return }
                    do {
                        try ScaffoldingService.shared.generateScaffold(name: moduleName, type: selectedType, outputURL: folder)
                    } catch {
                        alertText = error.localizedDescription
                        showAlert = true
                    }
                }
                .disabled(moduleName.isEmpty || outputFolder == nil)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .alert("Scaffold Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertText)
        }
    }
}

struct ScaffoldView_Previews: PreviewProvider {
    static var previews: some View {
        ScaffoldView()
    }
} 