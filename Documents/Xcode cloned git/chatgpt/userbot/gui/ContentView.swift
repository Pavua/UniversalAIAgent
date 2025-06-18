import SwiftUI

struct ContentView: View {
    enum Tab: Hashable {
        case telegram, llm, openai, lmstudio, finetune, analytics, crypto, settings
    }

    @State private var selected: Tab = .telegram

    var body: some View {
        TabView(selection: $selected) {
            TelegramView()
                .tabItem { Label("tab_telegram", systemImage: "paperplane") }
                .tag(Tab.telegram)

            LocalLLMView()
                .tabItem { Label("tab_local_llm", systemImage: "brain") }
                .tag(Tab.llm)

            OpenAIView()
                .tabItem { Label("tab_openai", systemImage: "bolt.horizontal.circle") }
                .tag(Tab.openai)

            AnalyticsView()
                .tabItem { Label("tab_analytics", systemImage: "chart.bar") }
                .tag(Tab.analytics)

            LMStudioView()
                .tabItem { Label("tab_lmstudio", systemImage: "network") }
                .tag(Tab.lmstudio)

            FineTuneView()
                .tabItem { Label("tab_finetune", systemImage: "wrench.and.screwdriver") }
                .tag(Tab.finetune)

            CryptoView()
                .tabItem { Label("tab_crypto", systemImage: "bitcoinsign.circle") }
                .tag(Tab.crypto)

            SettingsView(settings: SettingsModel.shared)
                .tabItem { Label("tab_settings", systemImage: "gear") }
                .tag(Tab.settings)
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

#Preview {
    ContentView()
}
