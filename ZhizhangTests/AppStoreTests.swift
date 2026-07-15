import XCTest
@testable import Zhizhang

@MainActor
final class AppStoreTests: XCTestCase {
    func testDemoTransactionsProduceExpectedMonthlyTotals() {
        let store = AppStore.demo

        XCTAssertEqual(store.totalIncome, 12_680)
        XCTAssertEqual(store.totalExpense, 4_286.8, accuracy: 0.001)
        XCTAssertEqual(store.balance, 8_393.2, accuracy: 0.001)
    }

    func testAddingExpenseUpdatesSelectedDayAndTotals() {
        let store = AppStore.demo
        let date = Calendar.current.startOfDay(for: .now)
        let expenseBefore = store.totalExpense

        store.addTransaction(
            kind: .expense,
            amount: 28.5,
            category: .dining,
            account: "支付宝",
            merchant: "午餐",
            note: "",
            date: date
        )

        XCTAssertEqual(store.totalExpense, expenseBefore + 28.5, accuracy: 0.001)
        XCTAssertTrue(store.transactions(on: date).contains { $0.merchant == "午餐" })
    }

    func testTabBarScrollBehaviorIgnoresSmallOffsetJitter() {
        var behavior = TabBarScrollBehavior()

        XCTAssertEqual(behavior.update(offset: 0), .expanded)
        XCTAssertEqual(behavior.update(offset: -3), .expanded)
        XCTAssertEqual(behavior.update(offset: -1), .expanded)
        XCTAssertEqual(behavior.update(offset: -5), .expanded)
    }

    func testTabBarScrollBehaviorCollapsesAtTwentyPoints() {
        var behavior = TabBarScrollBehavior()

        XCTAssertEqual(behavior.update(offset: 0), .expanded)
        XCTAssertEqual(behavior.update(offset: -19), .expanded)
        XCTAssertEqual(behavior.update(offset: -20), .collapsed)
    }

    func testTabBarScrollBehaviorExpandsAtSixteenPoints() {
        var behavior = TabBarScrollBehavior()
        _ = behavior.update(offset: 0)
        _ = behavior.update(offset: -40)

        XCTAssertEqual(behavior.update(offset: -25), .collapsed)
        XCTAssertEqual(behavior.update(offset: -24), .expanded)
    }

    func testTabBarScrollBehaviorExpandsNearTop() {
        var behavior = TabBarScrollBehavior()
        _ = behavior.update(offset: 0)
        _ = behavior.update(offset: -18)
        _ = behavior.update(offset: -40)

        XCTAssertEqual(behavior.update(offset: -8), .expanded)
    }

    func testTabBarScrollBehaviorDoesNotCountTopBounceAsDownwardScroll() {
        var behavior = TabBarScrollBehavior()

        XCTAssertEqual(behavior.update(offset: 0), .expanded)
        XCTAssertEqual(behavior.update(offset: 12), .expanded)
        XCTAssertEqual(behavior.update(offset: 0), .expanded)
        XCTAssertEqual(behavior.update(offset: -19), .expanded)
        XCTAssertEqual(behavior.update(offset: -20), .collapsed)
    }

    func testLockedScrollUpdatesBaselineWithoutReversingOrAccumulating() {
        var behavior = TabBarScrollBehavior()
        _ = behavior.update(offset: 0)
        _ = behavior.update(offset: -40)

        XCTAssertEqual(
            behavior.update(offset: -55, allowTransition: false),
            .collapsed
        )
        XCTAssertEqual(
            behavior.update(offset: -40, allowTransition: false),
            .collapsed
        )
        XCTAssertEqual(
            behavior.update(offset: -39, allowTransition: true),
            .collapsed
        )
        XCTAssertEqual(
            behavior.update(offset: -24, allowTransition: true),
            .expanded
        )
    }

    func testNavigationUsesRequestedFiveIcons() {
        XCTAssertEqual(
            AppTab.allCases.map(\.icon),
            [
                .system("list.bullet.rectangle.portrait"),
                .system("doc"),
                .system("plus"),
                .asset("PiggyBankTab"),
                .system("square.grid.2x2")
            ]
        )
    }

    func testBackgroundGlassRetractsAwayWhileActiveCircleRemains() {
        let expanded = TabBarAnimationModel(progress: 0, selectedTab: .bills)
        let collapsed = TabBarAnimationModel(progress: 1, selectedTab: .bills)

        XCTAssertEqual(expanded.leadingEdge, collapsed.leadingEdge, accuracy: 0.001)
        XCTAssertEqual(expanded.containerSize(expandedWidth: 336).width, 336, accuracy: 0.001)
        XCTAssertEqual(expanded.containerSize(expandedWidth: 336).height, 68, accuracy: 0.001)
        XCTAssertEqual(collapsed.containerSize(expandedWidth: 336).width, 0, accuracy: 0.001)
        XCTAssertEqual(collapsed.containerSize(expandedWidth: 336).height, 0, accuracy: 0.001)
    }

    func testActiveTabContinuouslyBecomesCenteredGlassCircle() {
        let model = TabBarAnimationModel(progress: 1, selectedTab: .bills)
        let state = model.activeState(expandedWidth: 336)

        XCTAssertEqual(state.centerX, 27, accuracy: 0.001)
        XCTAssertEqual(state.width, 54, accuracy: 0.001)
        XCTAssertEqual(state.height, 54, accuracy: 0.001)
        XCTAssertEqual(state.cornerRadius, 27, accuracy: 0.001)
    }

    func testInactiveTabDoesNotMoveTowardSelectedTab() {
        let expanded = TabBarAnimationModel(progress: 0, selectedTab: .bills)
        let middle = TabBarAnimationModel(progress: 0.5, selectedTab: .bills)
        let collapsed = TabBarAnimationModel(progress: 1, selectedTab: .bills)

        let startX = expanded.inactiveState(for: .more, expandedWidth: 336).centerX
        XCTAssertEqual(
            middle.inactiveState(for: .more, expandedWidth: 336).centerX,
            startX,
            accuracy: 0.001
        )
        XCTAssertEqual(
            collapsed.inactiveState(for: .more, expandedWidth: 336).centerX,
            startX,
            accuracy: 0.001
        )
        XCTAssertEqual(
            collapsed.inactiveState(for: .more, expandedWidth: 336).opacity,
            0,
            accuracy: 0.001
        )
        XCTAssertEqual(
            collapsed.inactiveState(for: .more, expandedWidth: 336).scale,
            0.92,
            accuracy: 0.001
        )
    }

    func testInactiveTabsWaitUntilContainerIsHalfExpanded() {
        let beforeThreshold = TabBarAnimationModel(progress: 0.51, selectedTab: .bills)
        let afterThreshold = TabBarAnimationModel(progress: 0.35, selectedTab: .bills)

        XCTAssertEqual(
            beforeThreshold.inactiveState(for: .more, expandedWidth: 336).opacity,
            0,
            accuracy: 0.001
        )
        XCTAssertGreaterThan(
            afterThreshold.inactiveState(for: .more, expandedWidth: 336).opacity,
            0
        )
    }

    func testActiveGlassAppearanceDoesNotChangeWithCollapseProgress() {
        let expanded = TabBarAnimationModel(
            progress: 0,
            selectedTab: .bills
        ).activeAppearance
        let collapsed = TabBarAnimationModel(
            progress: 1,
            selectedTab: .bills
        ).activeAppearance

        XCTAssertEqual(expanded, collapsed)
        XCTAssertEqual(collapsed.tintOpacity, 0.14, accuracy: 0.001)
        XCTAssertEqual(collapsed.iconRed, 0.88, accuracy: 0.001)
        XCTAssertEqual(collapsed.iconGreen, 0.20, accuracy: 0.001)
        XCTAssertEqual(collapsed.iconBlue, 0.32, accuracy: 0.001)
        XCTAssertEqual(collapsed.glassOpacity, 1, accuracy: 0.001)
        XCTAssertEqual(collapsed.saturation, 1, accuracy: 0.001)
    }

    func testCollapsedAccessibilityIdentifierUsesSelectedTab() {
        XCTAssertEqual(
            TabBarAnimationModel(progress: 1, selectedTab: .bills).collapsedTabIdentifier,
            "collapsed-tab-bills"
        )
        XCTAssertEqual(
            TabBarAnimationModel(progress: 1, selectedTab: .savings).collapsedTabIdentifier,
            "collapsed-tab-savings"
        )
    }
}
