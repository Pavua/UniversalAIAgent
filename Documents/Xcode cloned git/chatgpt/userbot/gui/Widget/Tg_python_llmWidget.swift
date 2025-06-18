import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let price: Double
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), price: 0.0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.example.tgpythonllm")
        let price = defaults?.double(forKey: "lastPrice_OKX_1m") ?? 0.0
        completion(SimpleEntry(date: Date(), price: price))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.example.tgpythonllm")
        let price = defaults?.double(forKey: "lastPrice_OKX_1m") ?? 0.0
        let entry = SimpleEntry(date: Date(), price: price)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct Tg_python_llmWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("BTC-USDT")
                .font(.headline)
            Text("\(entry.price, specifier: "%.2f") USD")
                .font(.title)
        }
        .padding()
    }
}

@main
struct Tg_python_llmWidget: Widget {
    let kind: String = "Tg_python_llmWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Tg_python_llmWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Userbot Widget")
        .description("Показывает текущую цену BTC-USDT")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}