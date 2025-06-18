import Charts
import SwiftData
import SwiftUI

struct AnalyticsView: View {
    @Query(sort: \Message.date) private var messages: [Message]

    init() {}

    var groupedData: [(date: Date, count: Int)] {
        let grouped = Dictionary(grouping: messages) { msg in
            Calendar.current.startOfDay(for: msg.date)
        }
        return grouped.map { (date: $0.key, count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Messages per Day")
                .font(.title)
            Chart(groupedData, id: \.date) { data in
                BarMark(
                    x: .value("Date", data.date, unit: .day),
                    y: .value("Messages", data.count)
                )
                .foregroundStyle(Color.accentColor)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
            .chartYAxis {
                AxisMarks()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AnalyticsView()
}
