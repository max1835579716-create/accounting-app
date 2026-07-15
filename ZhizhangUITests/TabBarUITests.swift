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
        XCTAssertFalse(app.buttons["tab-savings"].exists)
        keepScreenshot(app, named: "Bills retained in collapsed bar")

        collapsedBills.tap()

        XCTAssertTrue(app.descendants(matching: .any)["tab-bar-expanded"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["collapsed-tab-bills"].exists)
        XCTAssertTrue(app.staticTexts["账单"].firstMatch.exists)
        waitForStableFrame(app.descendants(matching: .any)["tab-bar-expanded"])
        keepScreenshot(app, named: "Bar expanded from retained icon")
    }

    func testExpandedTabBarSupportsHorizontalDragSelection() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["tab-bar-expanded"].waitForExistence(timeout: 5))

        let startTab = app.buttons["tab-analysis"]
        let targetTab = app.buttons["tab-savings"]
        XCTAssertTrue(startTab.waitForExistence(timeout: 5))
        XCTAssertTrue(targetTab.waitForExistence(timeout: 5))

        startTab.press(forDuration: 0.15, thenDragTo: targetTab)

        XCTAssertTrue(app.staticTexts["攒钱"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(
            targetTab.value as? String,
            "single-active-control"
        )
    }

    func testHeldDragDoesNotCommitPageBeforeRelease() {
        let app = XCUIApplication()
        app.launch()

        let expandedBar = app.descendants(matching: .any)["tab-bar-expanded"]
        let startTab = app.buttons["tab-analysis"]
        let targetTab = app.buttons["tab-savings"]
        XCTAssertTrue(expandedBar.waitForExistence(timeout: 5))
        XCTAssertTrue(startTab.waitForExistence(timeout: 5))
        XCTAssertTrue(targetTab.waitForExistence(timeout: 5))

        startTab.press(
            forDuration: 0.15,
            thenDragTo: targetTab,
            withVelocity: .slow,
            thenHoldForDuration: 3
        )

        XCTAssertTrue(app.staticTexts["攒钱"].firstMatch.waitForExistence(timeout: 5))
        let interactionValue = app.descendants(matching: .any)["tab-bar-expanded"].value as? String
        XCTAssertTrue(interactionValue?.contains("preReleaseCommit=false") == true)
    }

    func testSlightDragReturnsToCommittedPage() {
        let app = XCUIApplication()
        app.launch()

        let startTab = app.buttons["tab-analysis"]
        XCTAssertTrue(startTab.waitForExistence(timeout: 5))
        let start = startTab.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let nearby = start.withOffset(CGVector(dx: 3, dy: 0))

        start.press(forDuration: 0.15, thenDragTo: nearby)

        XCTAssertTrue(app.staticTexts["明细"].firstMatch.waitForExistence(timeout: 2))
        XCTAssertEqual(
            app.buttons["tab-analysis"].value as? String,
            "single-active-control"
        )
    }

    func testDragCanStartBetweenTabIcons() {
        let app = XCUIApplication()
        app.launch()

        let expandedBar = app.descendants(matching: .any)["tab-bar-expanded"]
        XCTAssertTrue(expandedBar.waitForExistence(timeout: 5))
        let blankStart = expandedBar.coordinate(
            withNormalizedOffset: CGVector(dx: 0.40, dy: 0.5)
        )
        let dragEnd = expandedBar.coordinate(
            withNormalizedOffset: CGVector(dx: 0.75, dy: 0.5)
        )

        blankStart.press(
            forDuration: 0.15,
            thenDragTo: dragEnd,
            withVelocity: .slow,
            thenHoldForDuration: 0.4
        )

        let selectedIdentifier = [
            "tab-analysis",
            "tab-bills",
            "tab-calendar",
            "tab-savings",
            "tab-more"
        ].first { identifier in
            app.buttons[identifier].value as? String == "single-active-control"
        }
        XCTAssertEqual(selectedIdentifier, "tab-calendar")
    }

    func testReverseDragCommitsOnlyOnRelease() {
        let app = XCUIApplication()
        app.launch()

        let savings = app.buttons["tab-savings"]
        let bills = app.buttons["tab-bills"]
        XCTAssertTrue(savings.waitForExistence(timeout: 5))
        savings.tap()
        XCTAssertTrue(app.staticTexts["攒钱"].firstMatch.waitForExistence(timeout: 5))

        savings.press(
            forDuration: 0.15,
            thenDragTo: bills,
            withVelocity: .slow,
            thenHoldForDuration: 0.4
        )

        XCTAssertTrue(app.staticTexts["账单"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(
            (app.descendants(matching: .any)["tab-bar-expanded"].value as? String)?
                .contains("preReleaseCommit=false") == true
        )
    }

    func testDragCanStartOnUnselectedIcon() {
        let app = XCUIApplication()
        app.launch()

        let unselectedStart = app.buttons["tab-bills"]
        let dragEnd = app.buttons["tab-savings"]
        XCTAssertTrue(unselectedStart.waitForExistence(timeout: 5))
        XCTAssertTrue(dragEnd.waitForExistence(timeout: 5))

        unselectedStart.press(
            forDuration: 0.15,
            thenDragTo: dragEnd,
            withVelocity: .slow,
            thenHoldForDuration: 0.4
        )

        XCTAssertEqual(
            app.buttons["tab-calendar"].value as? String,
            "single-active-control"
        )
    }

    func testRapidClicksLeaveExactlyOneCommittedTab() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["tab-analysis"].waitForExistence(timeout: 5))
        app.buttons["tab-more"].tap()
        app.buttons["tab-bills"].tap()
        app.buttons["tab-calendar"].tap()
        app.buttons["tab-savings"].tap()

        XCTAssertTrue(app.staticTexts["攒钱"].firstMatch.waitForExistence(timeout: 5))
        let selectedCount = [
            "tab-analysis",
            "tab-bills",
            "tab-calendar",
            "tab-savings",
            "tab-more"
        ].filter { identifier in
            app.buttons[identifier].value as? String == "single-active-control"
        }.count
        XCTAssertEqual(selectedCount, 1)
    }

    func testVisualSlowFullWidthDragAndFiveRapidReversals() {
        let app = XCUIApplication()
        app.launch()

        let expandedBar = app.descendants(matching: .any)["tab-bar-expanded"]
        let analysis = app.buttons["tab-analysis"]
        let more = app.buttons["tab-more"]
        XCTAssertTrue(expandedBar.waitForExistence(timeout: 5))
        XCTAssertTrue(analysis.waitForExistence(timeout: 5))
        XCTAssertTrue(more.waitForExistence(timeout: 5))

        analysis.press(
            forDuration: 0.2,
            thenDragTo: more,
            withVelocity: .slow,
            thenHoldForDuration: 0.6
        )
        XCTAssertEqual(more.value as? String, "single-active-control")

        var current = more
        for destination in [analysis, more, analysis, more, analysis] {
            current.press(
                forDuration: 0.05,
                thenDragTo: destination,
                withVelocity: .fast,
                thenHoldForDuration: 0.08
            )
            current = destination
        }

        XCTAssertEqual(analysis.value as? String, "single-active-control")
        XCTAssertTrue(
            (expandedBar.value as? String)?.contains("preReleaseCommit=false") == true
        )
        keepScreenshot(app, named: "Single icon liquid glass drag sequence")
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
