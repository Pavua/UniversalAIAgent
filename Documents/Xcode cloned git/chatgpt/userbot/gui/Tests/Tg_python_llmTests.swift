import SwiftData
import SwiftUI
@testable import Tg_python_llm
import XCTest

final class AnalyticsViewTests: XCTestCase {
    func testGroupedDataEmpty() {
        // При запуске без сообщений groupedData пустая
        let view = AnalyticsView()
        XCTAssertTrue(view.groupedData.isEmpty)
    }
}
