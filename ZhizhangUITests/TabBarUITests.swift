import XCTest

@MainActor
final class TabBarUITests: XCTestCase {
    func testTabBarMinimizesAndRestoresWhileScrolling() {
        let app = XCUIApplication()
        app.launch()

        let expandedBar = app.descendants(matching: .any)["tab-bar-expanded"]
        let collapsedBar = app.descendants(matching: .any)["tab-bar-collapsed"]
        XCTAssertTrue(expandedBar.waitForExistence(timeout: 5))
        app.buttons["tab-bills"].tap()
        XCTAssertTrue(app.staticTexts["账单"].firstMatch.waitForExistence(timeout: 5))
        waitForStableFrame(app.staticTexts["本月工资"].firstMatch)

        app.swipeUp()
        XCTAssertTrue(collapsedBar.waitForExistence(timeout: 5))
        XCTAssertFalse(expandedBar.exists)
        waitForStableFrame(app.staticTexts["本月工资"].firstMatch)
        keepScreenshot(app, named: "Tab bar collapsed")

        app.swipeDown()
        XCTAssertTrue(expandedBar.waitForExistence(timeout: 5))
        XCTAssertFalse(collapsedBar.exists)
        waitForStableFrame(expandedBar)
        keepScreenshot(app, named: "Tab bar expanded")
    }

    func testCollapsedBarRetainsSelectedTabAndExpandsOnTap() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["tab-bar-expanded"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["collapsed-tab-analysis"].exists)
        app.buttons["tab-bills"].tap()
        XCTAssertTrue(app.staticTexts["账单"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(
            app.buttons["tab-bills"].value as? String,
            "single-active-control"
        )
        waitForStableFrame(app.staticTexts["本月工资"].firstMatch)

        app.swipeUp()

        let collapsedBills = app.buttons["collapsed-tab-bills"]
        XCTAssertTrue(collapsedBills.waitForExistence(timeout: 5))
        XCTAssertEqual(
            app.buttons.matching(identifier: "collapsed-tab-bills").count,
            1
        )
        XCTAssertEqual(
            collapsedBills.value as? String,
            "single-active-control"
        )
        waitForStableFrame(collapsedBills)
        waitForStableFrame(app.staticTexts["本月工资"].firstMatch)
        XCTAssertFalse(app.buttons["tab-bills"].exists)
        XCTAssertFalse(app.buttons["tab-savings"].isEnabled)
        keepScreenshot(app, named: "Bills retained in collapsed bar")

        collapsedBills.tap()

        XCTAssertTrue(app.descendants(matching: .any)["tab-bar-expanded"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["collapsed-tab-bills"].exists)
        XCTAssertTrue(app.staticTexts["账单"].firstMatch.exists)
        waitForStableFrame(app.descendants(matching: .any)["tab-bar-expanded"])
        keepScreenshot(app, named: "Bar expanded from retained icon")
    }

    func testCollapsedBarRetainsSavingsTab() {
        let app = XCUIApplication()
        app.launchArguments.append("--many-savings-goals")
        app.launch()

        XCTAssertTrue(app.buttons["tab-savings"].waitForExistence(timeout: 5))
        app.buttons["tab-savings"].tap()
        XCTAssertTrue(app.staticTexts["攒钱"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["新电脑计划"].waitForExistence(timeout: 5))
        waitForStableFrame(app.staticTexts["新电脑计划"].firstMatch)

        app.swipeUp()

        XCTAssertTrue(app.buttons["collapsed-tab-savings"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["collapsed-tab-bills"].exists)
        waitForStableFrame(app.staticTexts["小荷包识别"].firstMatch)
        keepScreenshot(app, named: "Savings retained in collapsed bar")
    }

    func testCollapseAnimationCanReverseImmediately() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["tab-bills"].waitForExistence(timeout: 5))
        app.buttons["tab-bills"].tap()
        XCTAssertTrue(app.staticTexts["账单"].firstMatch.waitForExistence(timeout: 5))
        waitForStableFrame(app.staticTexts["本月工资"].firstMatch)

        app.swipeUp()

        let collapsedBills = app.buttons["collapsed-tab-bills"]
        XCTAssertTrue(collapsedBills.waitForExistence(timeout: 5))
        collapsedBills.tap()

        XCTAssertTrue(app.descendants(matching: .any)["tab-bar-expanded"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["collapsed-tab-bills"].exists)
        XCTAssertTrue(app.staticTexts["账单"].firstMatch.exists)
    }

    func testRapidScrollDoesNotExposeBothBarStates() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["tab-bills"].waitForExistence(timeout: 5))
        app.buttons["tab-bills"].tap()
        XCTAssertTrue(app.staticTexts["账单"].firstMatch.waitForExistence(timeout: 5))
        waitForStableFrame(app.staticTexts["本月工资"].firstMatch)

        app.swipeUp()
        app.swipeDown()
        app.swipeUp()

        let collapsedBar = app.descendants(matching: .any)["tab-bar-collapsed"]
        XCTAssertTrue(collapsedBar.waitForExistence(timeout: 5))
        XCTAssertFalse(app.descendants(matching: .any)["tab-bar-expanded"].exists)
        XCTAssertEqual(
            app.buttons.matching(identifier: "collapsed-tab-bills").count,
            1
        )
    }

    private func waitForStableFrame(
        _ element: XCUIElement,
        timeout: TimeInterval = 3
    ) {
        let deadline = Date().addingTimeInterval(timeout)
        var previousFrame = element.frame
        var stableSamples = 0

        while Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.12))
            let currentFrame = element.frame
            if currentFrame.equalTo(previousFrame) {
                stableSamples += 1
                if stableSamples >= 4 { return }
            } else {
                stableSamples = 0
                previousFrame = currentFrame
            }
        }

        XCTFail("UI did not settle before screenshot: \(element)")
    }

    private func keepScreenshot(_ app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
