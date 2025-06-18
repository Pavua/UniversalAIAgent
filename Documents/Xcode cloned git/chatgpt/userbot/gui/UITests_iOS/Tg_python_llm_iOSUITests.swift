import XCTest

final class Tg_python_llm_iOSUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCryptoTabDisplaysChart() throws {
        // Tap Crypto tab
        let cryptoButton = app.tabBars.buttons["Crypto"]
        XCTAssertTrue(cryptoButton.exists, "Crypto tab button should exist")
        cryptoButton.tap()

        // Check chart exists
        let chart = app.otherElements["CryptoChart"]
        XCTAssertTrue(chart.waitForExistence(timeout: 5), "Crypto chart should appear")
    }
}
