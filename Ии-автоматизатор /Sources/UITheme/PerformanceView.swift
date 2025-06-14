import SwiftUI
import Charts

struct PerformanceView: View {
    @StateObject private var monitor = PerformanceMonitor()
    @State private var isMonitoring: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Performance Monitor").font(.title2).bold().padding()
            Chart {
                ForEach(monitor.dataPoints) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Memory (GB)", point.memoryUsage)
                    )
                }
            }
            .chartYScale(domain: .automatic)
            .frame(height: 200)
            HStack {
                Button(isMonitoring ? "Stop" : "Start") {
                    if isMonitoring {
                        monitor.stop()
                    } else {
                        monitor.start()
                    }
                    isMonitoring.toggle()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding([.leading, .bottom])
        }
        .padding()
    }
}

struct PerformanceView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceView()
    }
} 