import XCTest

final class Tg_python_llmWatchUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testWatchAppLaunches() throws {
        // Verify main interface is visible
        XCTAssertTrue(app.otherElements.firstMatch.exists, "Watch app interface should appear")
    }
}
