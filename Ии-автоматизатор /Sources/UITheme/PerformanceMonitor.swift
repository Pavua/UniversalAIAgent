import Foundation

class PerformanceMonitor: ObservableObject {
    struct DataPoint: Identifiable {
        let id = UUID()
        let timestamp: Date
        let memoryUsage: Double  // ГБ
    }

    @Published var dataPoints: [DataPoint] = []
    private var timer: Timer?

    func start() {
        dataPoints.removeAll()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sample()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func sample() {
        // Текущее потребление памяти (используется физическая память для примера)
        let mem = ProcessInfo.processInfo.physicalMemory
        let usageGB = Double(mem) / (1024 * 1024 * 1024)
        let point = DataPoint(timestamp: Date(), memoryUsage: usageGB)
        DispatchQueue.main.async {
            self.dataPoints.append(point)
            if self.dataPoints.count > 60 {
                self.dataPoints.removeFirst()
            }
        }
    }
} 