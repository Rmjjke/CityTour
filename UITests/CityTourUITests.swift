import XCTest

final class CityTourUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testGenerateBarcelonaTour() throws {
        // 1. Tap center Generate button
        let generateBtn = app.buttons["generate_tab_button"]
        XCTAssertTrue(generateBtn.waitForExistence(timeout: 5))
        generateBtn.tap()
        snapshot("01_sheet_open")

        // 2. Type city
        let searchField = app.textFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Барселона")
        snapshot("02_city_typed")

        // 3. Tap settings button via coordinate (bypass keyboard interception)
        let settingsBtn = app.buttons["settings_button"]
        XCTAssertTrue(settingsBtn.waitForExistence(timeout: 5))
        settingsBtn.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        snapshot("03_after_settings_tap")

        // 4. Wait for settings to load
        Thread.sleep(forTimeInterval: 2)
        snapshot("04_after_wait")

        // Debug: print all buttons
        let allBtns = app.buttons.allElementsBoundByIndex
        var btnLabels = ""
        for btn in allBtns { btnLabels += "\(btn.identifier)|\(btn.label), " }
        XCTContext.runActivity(named: "Buttons: \(btnLabels)") { _ in }

        // 5. Find generate button
        let generateTourBtn = app.buttons["generate_tour_button"]
        XCTAssertTrue(generateTourBtn.waitForExistence(timeout: 10), "Generate tour button not found. Buttons: \(btnLabels)")
        generateTourBtn.tap()
        snapshot("05_loading")

        // 6. Wait for result
        let resultBar = app.navigationBars["Ваш маршрут"]
        let appeared = resultBar.waitForExistence(timeout: 120)
        snapshot("06_result")

        XCTAssertTrue(appeared, "Tour result should appear")
    }

    private func snapshot(_ name: String) {
        guard app.exists else { return }
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
