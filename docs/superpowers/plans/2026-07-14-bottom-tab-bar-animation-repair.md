# Bottom Tab Bar Animation Repair Implementation Plan

Date: 2026-07-14

## Goal

Keep one persistent selected Liquid Glass control while the bottom navigation transforms between an expanded capsule and a 54pt circle. The selected control must retain the same pale-pink translucent material and brand-red icon in both states.

## Constraints

- Change only bottom-tab animation, layering, and visibility state.
- Keep page UI, business data, navigation destinations, tab order, icons, and content layout unchanged.
- Never create a separate collapsed selected button or cross-fade two selected backgrounds.
- Never animate selected tint, material opacity, saturation, highlight, or icon color.
- Use `.spring(response: 0.36, dampingFraction: 0.88, blendDuration: 0.08)` for geometry.
- Keep 20pt collapse and 16pt expansion hysteresis with a 0.40-second transition lock.

## Implementation

1. Model container, active-control, and inactive-icon geometry in `TabBarAnimationModel`.
2. Extract `ActiveTabGlassAppearance` and `ActiveTabGlassStyle`; return the same appearance for every collapse progress value.
3. Render three layers: retracting outer glass, fixed-position inactive icons, and one persistent active button above them.
4. Retract the outer capsule from expanded size to zero. Move and reshape the active control independently to a 54pt circle.
5. Keep inactive icons at their expanded slot centers. Fade them from 1 to 0 and scale from 1 to 0.92; reveal them only after the capsule is more than half expanded.
6. Preserve existing scroll hysteresis, transition locking, safe-area padding, identifiers, and navigation behavior.

## Verification

- Add a failing unit test proving expanded and collapsed `activeAppearance` values are equal, then implement the style and turn it green.
- Run all `AppStoreTests`.
- Run `TabBarUITests`, including many savings goals, immediate reverse, and rapid scroll.
- Build and launch on iPhone 17 Pro / iOS 26.5.
- Capture expanded and collapsed screenshots and a 60fps transition recording.
- Inspect transition frames for tails, overlap, duplicate controls, color changes, or snapping.
- Inspect build and runtime logs for crashes, layout errors, and Swift runtime faults.

## Completion Criteria

- One selected view and one selected background throughout.
- Pale-pink translucent glass and red icon remain visually constant.
- Outer capsule retracts without a pink tail or rectangular fragment.
- Inactive icons do not move, overlap, flicker, or ghost.
- Expansion is a smooth reverse of collapse.
- Rapid scrolling exposes only one navigation state.
