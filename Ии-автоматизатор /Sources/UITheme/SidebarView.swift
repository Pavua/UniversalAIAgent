import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    var id: Self { self }
    case scaffold = "Scaffold"
    case chat = "Chat"
    case history = "History"
    case codegen = "CodeGen"
    case automation = "Automation"
    case dashboard = "Dashboard"
}

struct SidebarView: View {
    @Binding var selection: SidebarItem?

    var body: some View {
        List(SidebarItem.allCases, selection: $selection) { item in
            Label(item.rawValue, systemImage: icon(for: item))
                .tag(item as SidebarItem?)
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("AIHelper")
    }
}

func icon(for item: SidebarItem) -> String {
    switch item {
    case .scaffold: return "folder.badge.plus"
    case .chat: return "bubble.left.and.bubble.right"
    case .history: return "clock.arrow.circlepath"
    case .codegen: return "hammer"
    case .automation: return "gearshape.2"
    case .dashboard: return "waveform.path.ecg"
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SidebarView(selection: .constant(.chat))
            Text("Detail")
        }
    }
} 