# Calendar Tab Reselection Quick Entry Implementation Plan

> **For Codex:** Execute this plan test-first and verify each user-visible transition in Simulator before completion.

**Goal:** Keep `.calendar` as the formal center Tab and open the existing “记一笔” sheet only when the user explicitly taps that already-selected Tab again.

**Architecture:** The root tab shell owns the single quick-entry presentation state and presents the existing `AddTransactionSheet`. `FloatingTabBar` reports explicit reselections without changing its five-tab geometry or drag behavior. `CalendarLedgerView` receives the same presentation action for its remaining in-page entry point, while its header plus button is removed.

**Tech Stack:** SwiftUI, Swift Observation, XCTest, XCUITest, XcodeBuildMCP

---

### Task 1: Lock the behavior with tests

**Files:**
- Modify: `ZhizhangTests/AppStoreTests.swift`
- Modify: `ZhizhangUITests/TabBarUITests.swift`

1. Add a unit test proving a new `AppStore` defaults to `.calendar`.
2. Add unit tests proving an unselected target returns a normal selection action and an already-selected target returns a reselection action.
3. Add UI coverage for cold-start home selection, absence of the old header plus button, first tap from another Tab, and second tap on `.calendar`.
4. Run the focused tests and confirm they fail for the expected missing behavior.

### Task 2: Add explicit Tab reselection routing

**Files:**
- Modify: `Zhizhang/Components/FloatingTabBar.swift`
- Modify: `Zhizhang/Model/AppStore.swift`

1. Change the default formal selection to `.calendar`.
2. Add a small deterministic router that distinguishes selection from reselection using the pre-click selection.
3. Add an `onReselect` callback to `FloatingTabBar` without changing `AppTab.allCases`, icon order, lens positioning, or tab geometry.
4. Invoke reselection only for a real tap/accessibility activation, not a drag-release navigation.
5. Keep the center button label and width behavior unchanged.

### Task 3: Reuse one root-owned quick-entry presentation

**Files:**
- Modify: `Zhizhang/App/RootView.swift`
- Modify: `Zhizhang/Features/Calendar/CalendarLedgerView.swift`

1. Move the existing quick-entry destination state to `CustomTabShell`.
2. Present the existing `AddTransactionSheet` from that one state and retain the `--show-entry` UI-test launch path.
3. Handle only `.calendar` reselection by calling the shared presentation method.
4. Pass the same presentation action into `CalendarLedgerView` for its empty-state action.
5. Remove the header plus button, including its frame and hit area, without changing the page title layout.

### Task 4: Verify behavior and regression safety

**Files:**
- Verify: `ZhizhangTests/AppStoreTests.swift`
- Verify: `ZhizhangUITests/TabBarUITests.swift`

1. Run the focused unit and UI tests until green.
2. Run the full test suite and a Simulator build.
3. In Simulator, verify cold start, first center tap from each non-calendar Tab, second center tap, closing the sheet, rapid intentional double tap, and background/foreground state preservation.
4. Confirm the old header plus accessibility element is absent and the existing sheet is not duplicated.

### Task 5: Review and save the version

1. Review the final diff for unintended Tab, animation, or entry-flow changes.
2. Confirm the worktree contains only scoped changes.
3. Commit the verified implementation on `codex/calendar-repeat-tap-entry` for rollback safety.
