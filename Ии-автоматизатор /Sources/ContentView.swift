import Yams
import Charts

struct ContentView: View {
    var body: some View {
        TabView {
            AutomationView()
                .tabItem {
                    Label("Automation", systemImage: "gearshape.2")
                }
            PerformanceView()
                .tabItem {
                    Label("Dashboard", systemImage: "waveform.path.ecg")
                }
        }
    }
} 