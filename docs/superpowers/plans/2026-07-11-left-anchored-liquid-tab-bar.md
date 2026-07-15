# Left-Anchored Liquid Tab Bar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current conditional expanded/collapsed tab bar with a continuous, left-anchored Liquid Glass bar whose right edge retracts and whose selected tab remains visible.

**Architecture:** A pure `TabBarAnimationModel` converts normalized collapse progress into deterministic container and per-item geometry. `FloatingTabBar` keeps one persistent hierarchy, animates only explicit geometry/material properties, and derives the retained icon from the existing `selection` binding. Existing scroll state remains authoritative.

**Tech Stack:** Swift 6, SwiftUI, Observation, XCTest/XCUITest, XcodeBuildMCP, iOS 17 deployment target with iOS 26 Liquid Glass enhancement.

## Global Constraints

- Minimum supported version remains iOS 17.
- The expanded appearance and all five existing navigation actions remain unchanged.
- The bar is left anchored; do not use a whole-bar `scaleEffect`.
- `AppStore.selectedTab` and `AppStore.isTabBarCollapsed` remain the only product state sources.
- Collapsed width is 68 points and retains only the selected tab icon.
- The selected icon remains fully visible and scales to 1.04 at full collapse.
- Optional drag gestures are outside this implementation.
- Every code change is followed by the smallest relevant XcodeBuildMCP test or build.
- The workspace is not a Git repository, so commit steps are recorded as local verification checkpoints instead of Git commits.

---

## File Structure

- Modify `Zhizhang/Components/FloatingTabBar.swift`: add the pure animation model and replace the conditional view hierarchy with the continuous left-anchored bar.
- Modify `ZhizhangTests/AppStoreTests.swift`: add deterministic geometry, visibility, ordering, and selected-tab tests.
- Modify `ZhizhangUITests/TabBarUITests.swift`: assert collapsed content, expansion-only behavior, and the savings-tab retained icon.

### Task 1: Pure Tab Bar Animation Model

**Files:**
- Modify: `Zhizhang/Components/FloatingTabBar.swift`
- Test: `ZhizhangTests/AppStoreTests.swift`

**Interfaces:**
- Consumes: `AppTab.allCases`, selected `AppTab`, normalized progress in `0...1`, and expanded width.
- Produces: `TabBarAnimationModel`, `TabBarItemVisualState`, `containerWidth(expandedWidth:)`, and `itemState(for:)`.

- [ ] **Step 1: Write failing geometry and visibility tests**

Append these tests to `AppStoreTests`:

```swift
func testTabBarAnimationKeepsLeftEdgeAndRetractsToCollapsedWidth() {
    let expanded = TabBarAnimationModel(progress: 0, selectedTab: .bills)
    let collapsed = TabBarAnimationModel(progress: 1, selectedTab: .bills)

    XCTAssertEqual(expanded.leadingEdge, collapsed.leadingEdge, accuracy: 0.001)
    XCTAssertEqual(expanded.containerWidth(expandedWidth: 368), 368, accuracy: 0.001)
    XCTAssertEqual(collapsed.containerWidth(expandedWidth: 368), 68, accuracy: 0.001)
}

func testSelectedTabRemainsVisibleAndCentersWhenCollapsed() {
    let model = TabBarAnimationModel(progress: 1, selectedTab: .bills)
    let state = model.itemState(for: .bills)

    XCTAssertEqual(state.opacity, 1, accuracy: 0.001)
    XCTAssertEqual(state.centerX, 34, accuracy: 0.001)
    XCTAssertEqual(state.scale, 1.04, accuracy: 0.001)
}

func testNonSelectedTabsDoNotDisappearAtTheSameProgress() {
    let model = TabBarAnimationModel(progress: 0.46, selectedTab: .bills)

    XCTAssertLessThan(
        model.itemState(for: .more).opacity,
        model.itemState(for: .analysis).opacity
    )
}

func testCollapsedRetainedTabFollowsSelection() {
    let bills = TabBarAnimationModel(progress: 1, selectedTab: .bills)
    let savings = TabBarAnimationModel(progress: 1, selectedTab: .savings)

    XCTAssertEqual(bills.itemState(for: .bills).opacity, 1, accuracy: 0.001)
    XCTAssertEqual(bills.itemState(for: .savings).opacity, 0, accuracy: 0.001)
    XCTAssertEqual(savings.itemState(for: .savings).opacity, 1, accuracy: 0.001)
    XCTAssertEqual(savings.itemState(for: .bills).opacity, 0, accuracy: 0.001)
}
```

- [ ] **Step 2: Run the focused unit tests and verify RED**

Use XcodeBuildMCP `test_sim` with:

```text
extraArgs: [
  "-only-testing:ZhizhangTests/AppStoreTests/testTabBarAnimationKeepsLeftEdgeAndRetractsToCollapsedWidth",
  "-only-testing:ZhizhangTests/AppStoreTests/testSelectedTabRemainsVisibleAndCentersWhenCollapsed",
  "-only-testing:ZhizhangTests/AppStoreTests/testNonSelectedTabsDoNotDisappearAtTheSameProgress",
  "-only-testing:ZhizhangTests/AppStoreTests/testCollapsedRetainedTabFollowsSelection"
]
```

Expected: compilation fails because `TabBarAnimationModel` does not exist.

- [ ] **Step 3: Implement the minimal pure animation model**

Add above `FloatingTabBar` in `FloatingTabBar.swift`:

```swift
struct TabBarItemVisualState: Equatable {
    let centerX: CGFloat
    let opacity: Double
    let scale: CGFloat
    let isInteractive: Bool
}

struct TabBarAnimationModel {
    static let collapsedWidth: CGFloat = 68
    static let tabWidth: CGFloat = 68
    static let itemSpacing: CGFloat = 2
    static let horizontalInset: CGFloat = 8

    let progress: CGFloat
    let selectedTab: AppTab

    var leadingEdge: CGFloat { 0 }

    func containerWidth(expandedWidth: CGFloat) -> CGFloat {
        lerp(expandedWidth, Self.collapsedWidth, progress)
    }

    func itemState(for tab: AppTab) -> TabBarItemVisualState {
        let tabs = AppTab.allCases
        let index = CGFloat(tabs.firstIndex(of: tab) ?? 0)
        let expandedCenter = Self.horizontalInset
            + Self.tabWidth / 2
            + index * (Self.tabWidth + Self.itemSpacing)

        if tab == selectedTab {
            return TabBarItemVisualState(
                centerX: lerp(expandedCenter, Self.collapsedWidth / 2, progress),
                opacity: 1,
                scale: lerp(1, 1.04, progress),
                isInteractive: progress < 0.5
            )
        }

        let order = CGFloat(tabs.count - 1 - Int(index))
        let fadeStart = 0.10 + order * 0.105
        let opacity = 1 - smoothstep(fadeStart, fadeStart + 0.34, progress)
        return TabBarItemVisualState(
            centerX: lerp(expandedCenter, Self.collapsedWidth / 2, progress),
            opacity: opacity,
            scale: 1,
            isInteractive: progress < 0.18 && opacity > 0.9
        )
    }

    private func lerp(_ start: CGFloat, _ end: CGFloat, _ value: CGFloat) -> CGFloat {
        start + (end - start) * min(max(value, 0), 1)
    }

    private func smoothstep(_ lower: CGFloat, _ upper: CGFloat, _ value: CGFloat) -> Double {
        let normalized = min(max((value - lower) / (upper - lower), 0), 1)
        return Double(normalized * normalized * (3 - 2 * normalized))
    }
}
```

- [ ] **Step 4: Run the focused unit tests and verify GREEN**

Run the same XcodeBuildMCP `test_sim` invocation.

Expected: all four focused tests pass with zero failures.

- [ ] **Step 5: Record the local checkpoint**

Run:

```text
git status --short
```

Expected in this workspace: `fatal: not a git repository`; record the changed files using `ls -l` and continue without a commit.

### Task 2: Continuous Left-Anchored SwiftUI Bar

**Files:**
- Modify: `Zhizhang/Components/FloatingTabBar.swift`
- Test: `ZhizhangTests/AppStoreTests.swift`

**Interfaces:**
- Consumes: `Binding<AppTab>`, `Binding<Bool>`, `TabBarAnimationModel`, `accessibilityReduceMotion`.
- Produces: one persistent `FloatingTabBar` hierarchy with `tab-bar-expanded`, `tab-bar-collapsed`, and `collapsed-tab-<rawValue>` identifiers.

- [ ] **Step 1: Write failing accessibility-state test**

Append to `AppStoreTests`:

```swift
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
```

- [ ] **Step 2: Run the focused test and verify RED**

Use XcodeBuildMCP `test_sim` with:

```text
extraArgs: [
  "-only-testing:ZhizhangTests/AppStoreTests/testCollapsedAccessibilityIdentifierUsesSelectedTab"
]
```

Expected: compilation fails because `collapsedTabIdentifier` does not exist.

- [ ] **Step 3: Add the identifier API and replace the conditional hierarchy**

Add to `TabBarAnimationModel`:

```swift
var collapsedTabIdentifier: String {
    "collapsed-tab-\(selectedTab.rawValue)"
}
```

Replace `FloatingTabBar` with a continuous implementation that follows this structure:

```swift
struct FloatingTabBar: View {
    @Binding var selection: AppTab
    @Binding var isCollapsed: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var collapseProgress: CGFloat = 0
    @State private var shadowProgress: CGFloat = 0

    private let expandedWidth: CGFloat = 358
    private let barHeight: CGFloat = 68
    private let collapseSpring = Animation.spring(response: 0.50, dampingFraction: 0.82)
    private let selectionSpring = Animation.spring(response: 0.32, dampingFraction: 0.82)

    var body: some View {
        let model = TabBarAnimationModel(progress: collapseProgress, selectedTab: selection)

        ZStack(alignment: .leading) {
            shadowSurface(progress: shadowProgress)
            glassSurface(model: model)
            navigationItems(model: model)
            collapsedExpansionButton(model: model)
        }
        .frame(maxWidth: .infinity, minHeight: barHeight, alignment: .leading)
        .padding(.leading, 16)
        .onAppear {
            collapseProgress = isCollapsed ? 1 : 0
            shadowProgress = collapseProgress
        }
        .onChange(of: isCollapsed) { _, collapsed in
            animateCollapse(to: collapsed ? 1 : 0)
        }
        .animation(selectionSpring, value: selection)
    }

    private func animateCollapse(to target: CGFloat) {
        let animation = reduceMotion
            ? Animation.easeOut(duration: 0.16)
            : collapseSpring
        withAnimation(animation) {
            collapseProgress = target
        }
        withAnimation(animation.delay(reduceMotion ? 0 : 0.045)) {
            shadowProgress = target
        }
    }

    private func glassSurface(model: TabBarAnimationModel) -> some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(.clear)
            .frame(width: model.containerWidth(expandedWidth: expandedWidth), height: barHeight)
            .glassPanel(cornerRadius: 34, interactive: true)
    }

    private func shadowSurface(progress: CGFloat) -> some View {
        let model = TabBarAnimationModel(progress: progress, selectedTab: selection)
        return RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(Color.accentColor.opacity(0.10))
            .blur(radius: 18)
            .offset(y: 10)
            .frame(width: model.containerWidth(expandedWidth: expandedWidth), height: barHeight)
            .allowsHitTesting(false)
    }

    private func navigationItems(model: TabBarAnimationModel) -> some View {
        ZStack(alignment: .leading) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab, model: model)
            }
        }
        .frame(width: model.containerWidth(expandedWidth: expandedWidth), height: barHeight, alignment: .leading)
        .clipped()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(isCollapsed ? "tab-bar-collapsed" : "tab-bar-expanded")
    }

    private func tabButton(_ tab: AppTab, model: TabBarAnimationModel) -> some View {
        let state = model.itemState(for: tab)
        return Button {
            guard !isCollapsed else { return }
            withAnimation(selectionSpring) { selection = tab }
        } label: {
            ZStack {
                if selection == tab { activeTabBackground }
                AppTabIconView(tab: tab)
                    .foregroundStyle(selection == tab ? Color.accentColor : Color.primary.opacity(0.72))
            }
            .frame(width: 68, height: 54)
        }
        .buttonStyle(.plain)
        .position(x: state.centerX, y: barHeight / 2)
        .opacity(state.opacity)
        .scaleEffect(reduceMotion ? 1 : state.scale)
        .allowsHitTesting(state.isInteractive && !isCollapsed)
        .accessibilityHidden(state.opacity < 0.9 || isCollapsed)
        .accessibilityLabel(tab.title)
        .accessibilityIdentifier("tab-\(tab.rawValue)")
    }

    private func collapsedExpansionButton(model: TabBarAnimationModel) -> some View {
        Button {
            guard isCollapsed else { return }
            isCollapsed = false
        } label: {
            Color.clear.frame(width: 68, height: barHeight)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(isCollapsed)
        .accessibilityHidden(!isCollapsed)
        .accessibilityLabel("展开导航栏，当前页面：\(selection.title)")
        .accessibilityIdentifier(model.collapsedTabIdentifier)
    }
}
```

Keep the existing `activeTabBackground` and `AppTabIconView`; remove the obsolete namespace and `morphingGlassIdentity` helper only after the persistent hierarchy compiles.

- [ ] **Step 4: Run the focused unit test and build**

First run the focused XcodeBuildMCP `test_sim` invocation from Step 2.

Expected: the identifier test passes.

Then run XcodeBuildMCP `build_sim`.

Expected: `Zhizhang` builds successfully without Swift errors.

- [ ] **Step 5: Capture the first simulator visual checkpoint**

Run XcodeBuildMCP `build_run_sim`, then `screenshot` and `snapshot_ui`.

Expected: the expanded bar retains all five buttons and `tab-bar-expanded` is present.

### Task 3: UI Behavior and Retained-Icon Regression Tests

**Files:**
- Modify: `ZhizhangUITests/TabBarUITests.swift`
- Modify if visual tuning is required: `Zhizhang/Components/FloatingTabBar.swift`

**Interfaces:**
- Consumes: runtime identifiers `tab-bar-expanded`, `tab-bar-collapsed`, `collapsed-tab-bills`, `collapsed-tab-savings`, `tab-bills`, and `tab-savings`.
- Produces: XCUITest evidence for selected-icon retention and expansion-only collapsed interaction.

- [ ] **Step 1: Replace the current UI test with explicit retained-icon cases**

Use this test body:

```swift
func testCollapsedBarRetainsSelectedTabAndExpandsOnTap() {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.descendants(matching: .any)["tab-bar-expanded"].waitForExistence(timeout: 5))
    app.buttons["tab-bills"].tap()
    XCTAssertTrue(app.staticTexts["账单"].firstMatch.waitForExistence(timeout: 5))

    app.swipeUp()

    let collapsedBills = app.buttons["collapsed-tab-bills"]
    XCTAssertTrue(collapsedBills.waitForExistence(timeout: 5))
    XCTAssertFalse(app.buttons["tab-savings"].isHittable)
    keepScreenshot(app, named: "Bills retained in collapsed bar")

    collapsedBills.tap()

    XCTAssertTrue(app.descendants(matching: .any)["tab-bar-expanded"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["账单"].firstMatch.exists)
    keepScreenshot(app, named: "Bar expanded from retained icon")
}

func testCollapsedBarRetainsSavingsTab() {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.buttons["tab-savings"].waitForExistence(timeout: 5))
    app.buttons["tab-savings"].tap()
    XCTAssertTrue(app.staticTexts["攒钱"].firstMatch.waitForExistence(timeout: 5))

    app.swipeUp()

    XCTAssertTrue(app.buttons["collapsed-tab-savings"].waitForExistence(timeout: 5))
    XCTAssertFalse(app.buttons["collapsed-tab-bills"].exists)
    keepScreenshot(app, named: "Savings retained in collapsed bar")
}
```

- [ ] **Step 2: Run only the two UI tests and verify failures describe missing behavior**

Use XcodeBuildMCP `test_sim` with:

```text
extraArgs: [
  "-only-testing:ZhizhangUITests/TabBarUITests/testCollapsedBarRetainsSelectedTabAndExpandsOnTap",
  "-only-testing:ZhizhangUITests/TabBarUITests/testCollapsedBarRetainsSavingsTab"
]
```

Expected before final accessibility tuning: at least one test fails because a retained-icon identifier or collapsed hit target is missing or incorrectly exposed. If both already pass, temporarily assert an intentionally wrong retained identifier to prove the test can fail, restore the correct assertion, and rerun.

- [ ] **Step 3: Make the minimal accessibility and hit-testing corrections**

Ensure `FloatingTabBar` exposes exactly one collapsed button with the selected identifier and that hidden tab buttons use both:

```swift
.allowsHitTesting(false)
.accessibilityHidden(true)
```

Do not create a second visual icon; the collapsed button remains a transparent hit target over the continuously rendered selected icon.

- [ ] **Step 4: Run the two UI tests and verify GREEN**

Run the same XcodeBuildMCP `test_sim` invocation.

Expected: both UI tests pass and save three screenshots.

- [ ] **Step 5: Run the full regression suite**

Run XcodeBuildMCP `test_sim` without `-only-testing` filters.

Expected: all unit and UI tests pass, with zero failures and zero skipped tests.

### Task 4: Runtime Motion, Material, and Completion Audit

**Files:**
- Modify only if runtime evidence contradicts the spec: `Zhizhang/Components/FloatingTabBar.swift`
- Reference: `docs/superpowers/specs/2026-07-11-left-anchored-liquid-tab-bar-design.md`

**Interfaces:**
- Consumes: built `com.max.zhizhang` app on the configured iPhone 17 Pro simulator.
- Produces: screenshots, UI snapshots, logs, and requirement-by-requirement evidence.

- [ ] **Step 1: Build and launch the final app**

Use XcodeBuildMCP `build_run_sim` with the established defaults.

Expected: build, installation, and launch succeed.

- [ ] **Step 2: Verify the expanded state**

Use `snapshot_ui` and `screenshot`.

Expected: all five navigation buttons exist, the bar starts at the existing left margin, and the expanded appearance matches the baseline.

- [ ] **Step 3: Verify the bills collapsed state**

Tap `tab-bills`, swipe the bills scroll view upward, wait for `collapsed-tab-bills`, then capture `snapshot_ui` and `screenshot`.

Expected: only the bills retained button is exposed; the capsule remains at the left margin and is approximately 68 points wide.

- [ ] **Step 4: Verify expansion and savings retention**

Tap `collapsed-tab-bills`, wait for `tab-bar-expanded`, tap `tab-savings`, swipe upward, wait for `collapsed-tab-savings`, then capture another screenshot.

Expected: tapping the capsule only expands; the savings page remains selected; the second collapse retains the savings icon.

- [ ] **Step 5: Verify reversible motion and reduced-motion behavior**

Trigger collapse and expansion in quick succession while observing the simulator. Then enable Reduce Motion in Simulator accessibility settings and repeat.

Expected: no flashes, hierarchy jumps, or center-collapse; Reduce Motion removes staggering and 1.04 scaling while retaining a short width/fade transition.

- [ ] **Step 6: Inspect fresh logs**

Read the runtime and OSLog files produced by the final `build_run_sim` call and search for:

```text
error:|fatal|crash|exception|assert|Swift runtime|layout ambiguity
```

Expected: no app-originated crash, assertion, Swift runtime error, or layout ambiguity.

- [ ] **Step 7: Audit every acceptance criterion**

Compare the final code, tests, screenshots, UI snapshots, and logs against all bullets in Section 11 of the design spec.

Expected: each required criterion has direct evidence; optional drag gestures remain explicitly out of scope.
