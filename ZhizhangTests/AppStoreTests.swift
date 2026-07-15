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
        XCTAssertEqual(collapsed.tintOpacity, 0.08, accuracy: 0.001)
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

    func testLiquidTabGeometryInterpolatesBetweenMeasuredCenters() {
        let centers: [CGFloat] = [24, 96, 216]

        XCTAssertEqual(
            LiquidTabGeometry.progress(for: 60, centers: centers),
            0.5,
            accuracy: 0.001
        )
        XCTAssertEqual(
            LiquidTabGeometry.progress(for: 156, centers: centers),
            1.5,
            accuracy: 0.001
        )
        XCTAssertEqual(
            LiquidTabGeometry.centerX(for: 1.5, centers: centers),
            156,
            accuracy: 0.001
        )
    }

    func testDragPreviewNeverMutatesCommittedIndex() {
        var state = LiquidTabSelectionState(committedIndex: 0)
        let centers: [CGFloat] = [24, 96, 168, 240, 312]

        state.beginDrag()
        state.updateDrag(translationX: 198, centers: centers)

        XCTAssertEqual(state.committedIndex, 0)
        XCTAssertEqual(state.previewIndex, 3)
        XCTAssertEqual(state.selectionProgress, 2.75, accuracy: 0.001)
    }

    func testRightwardDragExtendsFrontEdgeMoreThanRearEdge() {
        let edges = LiquidTabGeometry.draggedEdges(
            centerX: 120,
            velocityX: 900,
            baseWidth: 54,
            reduceMotion: false
        )
        let frontExtension = edges.maxX - (120 + 27)
        let rearExtension = (120 - 27) - edges.minX

        XCTAssertGreaterThan(frontExtension, rearExtension)
        XCTAssertLessThanOrEqual(edges.width, 54 * 1.8 + 0.001)
    }

    func testLeftwardDragExtendsFrontEdgeMoreThanRearEdge() {
        let edges = LiquidTabGeometry.draggedEdges(
            centerX: 120,
            velocityX: -900,
            baseWidth: 54,
            reduceMotion: false
        )
        let frontExtension = (120 - 27) - edges.minX
        let rearExtension = edges.maxX - (120 + 27)

        XCTAssertGreaterThan(frontExtension, rearExtension)
        XCTAssertLessThanOrEqual(edges.width, 54 * 1.8 + 0.001)
    }

    func testReleaseBelowDragThresholdReturnsCommittedTab() {
        XCTAssertEqual(
            LiquidTabGeometry.releaseTarget(
                progress: 1.9,
                predictedTranslationRemainder: 80,
                centers: [24, 96, 168, 240, 312],
                committedIndex: 0,
                exceededDragThreshold: false
            ),
            0
        )
    }

    func testIndependentEdgesStayBoundedAndSettleRound() {
        var motion = LiquidLensMotionState(centerX: 24, width: 54)

        for _ in 0..<180 {
            motion.step(
                towardCenterX: 240,
                baseWidth: 54,
                deltaTime: 1 / 120,
                reduceMotion: false
            )
            XCTAssertLessThanOrEqual(motion.edges.width, 54 * 1.8 + 0.001)
        }

        XCTAssertEqual(motion.edges.centerX, 240, accuracy: 0.35)
        XCTAssertEqual(motion.edges.width, 54, accuracy: 0.35)
    }

    func testLiquidTabIconAtLensCenterUsesFullContinuousInfluence() {
        let state = LiquidTabIconVisualModel.state(
            tabCenterX: 120,
            lensEdges: LiquidLensEdges(minX: 93, maxX: 147),
            baseWidth: 54,
            reduceMotion: false
        )

        XCTAssertEqual(state.influence, 1, accuracy: 0.001)
        XCTAssertEqual(state.scale, 1.075, accuracy: 0.001)
        XCTAssertEqual(state.offsetY, -1.25, accuracy: 0.001)
        XCTAssertEqual(state.brightness, 0.025, accuracy: 0.001)
    }

    func testLiquidTabIconInfluenceFallsOffSmoothlyWithoutLeavingRange() {
        let edges = LiquidLensEdges(minX: 93, maxX: 147)
        let partial = LiquidTabIconVisualModel.state(
            tabCenterX: 147,
            lensEdges: edges,
            baseWidth: 54,
            reduceMotion: false
        )
        let outside = LiquidTabIconVisualModel.state(
            tabCenterX: 220,
            lensEdges: edges,
            baseWidth: 54,
            reduceMotion: false
        )

        XCTAssertGreaterThan(partial.influence, 0)
        XCTAssertLessThan(partial.influence, 1)
        XCTAssertEqual(outside.influence, 0, accuracy: 0.001)
        XCTAssertGreaterThanOrEqual(partial.scale, 1)
        XCTAssertLessThanOrEqual(partial.scale, 1.09)
    }

    func testReduceMotionKeepsContinuousIconFeedbackButLimitsMovement() {
        let state = LiquidTabIconVisualModel.state(
            tabCenterX: 120,
            lensEdges: LiquidLensEdges(minX: 80, maxX: 160),
            baseWidth: 54,
            reduceMotion: true
        )

        XCTAssertEqual(state.influence, 1, accuracy: 0.001)
        XCTAssertEqual(state.scale, 1.025, accuracy: 0.001)
        XCTAssertEqual(state.offsetY, -0.5, accuracy: 0.001)
        XCTAssertEqual(state.brightness, 0.01, accuracy: 0.001)
    }
}
