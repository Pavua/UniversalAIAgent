import XCTest

final class Tg_python_llmUITests: XCTestCase {
    func testAppLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        // Проверяем, что окно приложения открылось
        XCTAssertTrue(app.windows.count > 0)
    }
}
