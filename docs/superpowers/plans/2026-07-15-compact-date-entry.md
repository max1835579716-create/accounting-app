# Compact Date Entry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the custom keypad's top-right key the only transaction-date entry while widening the existing supplementary-note field.

**Architecture:** `AddTransactionSheet` owns one full `Date` named `selectedDate` and a temporary `draftDate`. `AmountKeypad` receives a display-only title and date-button action; a focused date-picker sheet edits the draft and commits it only on Done. `AppStore.addTransaction` continues receiving the full `Date`.

**Tech Stack:** Swift 6, SwiftUI, XCTest, XCUITest, iOS 17+

## Global Constraints

- Preserve amount entry, keypad arrangement, plus/minus/delete/complete behavior, transaction type/category/account/camera/save logic, theme, radii, glass effects, and animations.
- Remove the inline full-date `DatePicker` and all of its layout and hit-testing area.
- Keep exactly one transaction-date source in the entry page and save it as `Date`.
- The keypad date title is `今天` for today and unpadded `month.day` otherwise.
- Cancel must discard draft changes; Done must commit them.

---

### Task 1: Compact date-title behavior

**Files:**
- Modify: `ZhizhangTests/AppStoreTests.swift`
- Modify: `Zhizhang/Components/AmountKeypad.swift`

**Interfaces:**
- Produces: `CompactDateTitle.text(for:calendar:) -> String`
- Produces: `AmountKeypad.init(value:dateTitle:onDateTap:onComplete:)`

- [ ] **Step 1: Write failing unit tests**

Add tests asserting today produces `今天`, and dates built from calendar components produce `7.18`, `8.3`, and `11.6` without zero padding.

- [ ] **Step 2: Verify the tests fail**

Run `xcodebuild test -project Zhizhang.xcodeproj -scheme Zhizhang -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:ZhizhangTests/AppStoreTests` and expect failure because `CompactDateTitle` does not exist.

- [ ] **Step 3: Implement the title and keypad interface**

Use `calendar.isDateInToday(date)` and `calendar.dateComponents([.month, .day], from: date)`. Return `"\(month).\(day)"` only when both components are present. Give the date label one line and the existing flexible key frame so the fourth column remains stable.

- [ ] **Step 4: Verify unit tests pass**

Run the same focused test command and expect all selected tests to pass.

### Task 2: Date sheet and input-bar layout

**Files:**
- Modify: `Zhizhang/Features/Entry/AddTransactionSheet.swift`

**Interfaces:**
- Consumes: `CompactDateTitle.text(for:calendar:)`
- Consumes: `AmountKeypad.init(value:dateTitle:onDateTap:onComplete:)`
- Produces: local `selectedDate`, `draftDate`, and item-driven date sheet

- [ ] **Step 1: Add UI regression coverage**

Add XCUITest coverage for launching the entry page, finding one keypad date button, confirming the supplementary-note field remains editable, and opening/cancelling the native picker without committing.

- [ ] **Step 2: Verify the UI test fails**

Run the focused UI test and expect failure because the keypad date button has no action or accessibility identifier.

- [ ] **Step 3: Replace the inline date picker**

Rename the entry page's formal date state from `date` to `selectedDate`, remove the inline full-date `DatePicker`, let the existing note field use `maxWidth: .infinity`, keep the account at intrinsic width and camera button fixed, and present an item-driven bottom sheet. Initialize its draft from `selectedDate`; Cancel dismisses, and Done assigns the draft to `selectedDate` before dismissing.

- [ ] **Step 4: Preserve the full-date save path**

Pass `selectedDate` directly to `AppStore.addTransaction(... date:)`; never parse the keypad title.

- [ ] **Step 5: Verify focused UI coverage passes**

Run the focused UI test and expect it to pass.

### Task 3: Full build and Simulator acceptance

**Files:**
- Verify: `Zhizhang/Features/Entry/AddTransactionSheet.swift`
- Verify: `Zhizhang/Components/AmountKeypad.swift`
- Verify: `Zhizhang/Model/AppStore.swift`

**Interfaces:**
- Consumes the completed entry flow.

- [ ] **Step 1: Run all tests and build**

Run the full `xcodebuild test` suite followed by `xcodebuild build` for a booted simulator, expecting exit code 0 and zero test failures.

- [ ] **Step 2: Inspect the running entry page**

Confirm there is no full-date pill or empty hit area, the note field fills the center, and the account/camera controls remain at the edges on the selected simulator.

- [ ] **Step 3: Exercise date cases**

Verify `今天`, `7.18`, `8.3`, and `11.6`; reopen a chosen date, verify Cancel preserves it, and Done commits it.

- [ ] **Step 4: Save a transaction**

Enter amount, merchant, supplementary note, and a non-today date; save; then verify the resulting calendar day contains the transaction and uses the complete selected date.

- [ ] **Step 5: Review and commit**

Check `git diff --check`, review the scoped diff, and commit the verified change on `codex/compact-date-entry`.
