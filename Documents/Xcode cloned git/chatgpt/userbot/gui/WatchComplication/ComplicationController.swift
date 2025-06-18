import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    private let defaults = UserDefaults(suiteName: "group.com.example.tgpythonllm")

    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward])
    }

    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = CLKSimpleTextTemplate(textProvider: CLKSimpleTextProvider(text: "--.-- USD"))
        handler(template)
    }

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let price = defaults?.double(forKey: "lastPrice_OKX_1m") ?? 0.0
        let template = CLKSimpleTextTemplate(textProvider: CLKSimpleTextProvider(text: String(format: "%.2f USD", price)))
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var entries: [CLKComplicationTimelineEntry] = []
        for i in 1...limit {
            let nextDate = Calendar.current.date(byAdding: .minute, value: 5 * i, to: date)!
            let price = defaults?.double(forKey: "lastPrice_OKX_1m") ?? 0.0
            let template = CLKSimpleTextTemplate(textProvider: CLKSimpleTextProvider(text: String(format: "%.2f USD", price)))
            entries.append(CLKComplicationTimelineEntry(date: nextDate, complicationTemplate: template))
        }
        handler(entries)
    }
}