import XCTest

final class CityTourUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testGenerateBarcelonaTour() throws {
        // 1. Type city name
        let searchField = app.textFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Барселона")

        // Screenshot: city entered
        let screenshot1 = app.screenshot()
        let attach1 = XCTAttachment(screenshot: screenshot1)
        attach1.name = "01_city_entered"
        attach1.lifetime = .keepAlways
        add(attach1)

        // 2. Tap "Настроить тур"
        let settingsButton = app.buttons["Настроить тур"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3))
        settingsButton.tap()

        // Screenshot: settings screen
        let screenshot2 = app.screenshot()
        let attach2 = XCTAttachment(screenshot: screenshot2)
        attach2.name = "02_settings_screen"
        attach2.lifetime = .keepAlways
        add(attach2)

        // 3. Tap generate button
        let generateButton = app.buttons["Сгенерировать мой тур"]
        XCTAssertTrue(generateButton.waitForExistence(timeout: 3))
        generateButton.tap()

        // Screenshot: loading state
        let screenshot3 = app.screenshot()
        let attach3 = XCTAttachment(screenshot: screenshot3)
        attach3.name = "03_loading"
        attach3.lifetime = .keepAlways
        add(attach3)

        // 4. Wait for result (up to 60 seconds for API call)
        let resultTitle = app.staticTexts["Ваш маршрут"]
        let appeared = resultTitle.waitForExistence(timeout: 60)

        // Screenshot: result
        let screenshot4 = app.screenshot()
        let attach4 = XCTAttachment(screenshot: screenshot4)
        attach4.name = "04_result"
        attach4.lifetime = .keepAlways
        add(attach4)

        XCTAssertTrue(appeared, "Tour result screen should appear after generation")
    }
}
