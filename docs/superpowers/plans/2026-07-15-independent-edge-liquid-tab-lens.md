# Independent-Edge Liquid Tab Lens Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the expanded SwiftUI bottom navigation as one continuously draggable native Liquid Glass lens with independent edges and release-only page commits.

**Architecture:** Keep committed navigation in the existing binding, while a value-type interaction model owns continuous preview progress and a value-type motion model owns the two lens edges. Measure real Tab centers with a preference key, render normal and selected content layers, and bind one zero-distance drag gesture to the common expanded-bar parent.

**Tech Stack:** Swift 6, SwiftUI, iOS 17 deployment with iOS 26 Liquid Glass availability, XCTest, XCUITest.

## Global Constraints

- Do not change page business logic, data, body layout, Tab count/order/icons, current brand theme, current glass color Token, collapse behavior, collapsed button, or collapse/expand animation.
- Never write the committed selection during `DragGesture.onChanged`.
- Render exactly one active lens and keep every visual layer hit-test disabled.
- Use the reference video for motion and optics only; never copy its green.

---

### Task 1: Pure Interaction and Edge Models

**Files:**
- Modify: `Zhizhang/Components/FloatingTabBar.swift`
- Test: `ZhizhangTests/AppStoreTests.swift`

**Interfaces:**
- Produces: `LiquidTabGeometry.progress(for:centers:)`, `centerX(for:centers:)`, `LiquidLensMotionState`, and release-target helpers.

- [ ] Write tests proving real-center interpolation, preview-only drag updates, direction-specific edge extension, the `1.8x` width cap, and convergence to a round target.
- [ ] Run `xcodebuild test -only-testing:ZhizhangTests` and confirm the new tests fail for missing types.
- [ ] Implement the minimal pure value models without SwiftUI animation.
- [ ] Re-run the focused unit tests and confirm they pass.

### Task 2: Expanded-Bar Composition and Unified Gesture

**Files:**
- Modify: `Zhizhang/Components/FloatingTabBar.swift`
- Test: `ZhizhangUITests/TabBarUITests.swift`

**Interfaces:**
- Consumes: the pure geometry and motion models from Task 1.
- Produces: one `LiquidLens`, `TabContentLayer`, `SelectedContentMaskLayer`, real-center preferences, and a root `DragGesture(minimumDistance: 0)`.

- [ ] Add UI tests for drag release selection, slight-drag cancellation, blank-space drag, and retained collapsed behavior.
- [ ] Run the focused UI test and confirm the required expanded interaction is not yet present.
- [ ] Replace expanded Buttons with hit-test-free visual/accessibility content and bind the single gesture at the common parent.
- [ ] Split committed selection, continuous progress, preview index, and independent edge states; keep `onChanged` preview-only and commit once in `onEnded`.
- [ ] Render base and masked brand-color content without stretching icons.

### Task 3: Native Glass and Edge Animation

**Files:**
- Modify: `Zhizhang/Components/FloatingTabBar.swift`

**Interfaces:**
- Consumes: current `ActiveTabGlassAppearance.standard` unchanged.
- Produces: one iOS 26 native interactive glass lens and an iOS 17–25 fallback.

- [ ] Delete the manual white highlight capsule, white dot, gradient tint overlay, duplicate stroke, and icon embedded inside the lens.
- [ ] Drive drag edges directly and snap/click edges through the bounded display-link-style task loop; retarget from current presentation state.
- [ ] Apply Reduce Motion limits while preserving drag and release commit.
- [ ] Build and fix every compiler error before continuing.

### Task 4: Full Verification

**Files:**
- Verify: `Zhizhang/Components/FloatingTabBar.swift`
- Verify: `ZhizhangTests/AppStoreTests.swift`
- Verify: `ZhizhangUITests/TabBarUITests.swift`

- [ ] Run all unit and UI tests and require zero failures.
- [ ] Build and run the app on the booted iPhone 17 Pro / iOS 26.5 Simulator.
- [ ] Use mouse drag from selected icon, unselected icon, inter-Tab blank space, and bar padding; hold between Tabs for three seconds and verify the page title remains the committed page.
- [ ] Verify release commits exactly once, slight drag returns, reverse drag works, rapid direction changes keep one lens, and rapid clicks retarget without jumps.
- [ ] Recheck the diff for unchanged theme/glass color values and untouched collapse/page business behavior.
