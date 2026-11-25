import XCTest

/// UI tests launch the app with `-uiTesting`, which swaps in mock data (see AppEnvironment.bootstrap).
final class StarterAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        return app
    }

    @MainActor
    func testItemsListShowsSampleData() throws {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["Connect Claude Agent in Xcode"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testOpeningAnItemShowsDetail() throws {
        let app = launchApp()

        let title = app.staticTexts["Write the first feature"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.tap()

        XCTAssertTrue(app.navigationBars["Item"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsTabOpens() throws {
        let app = launchApp()

        app.tabBars.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
    }
}
