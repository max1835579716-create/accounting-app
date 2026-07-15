import SwiftUI

struct TabBarInactiveVisualState: Equatable {
    let centerX: CGFloat
    let opacity: Double
    let scale: CGFloat
    let isInteractive: Bool
}

struct TabBarActiveVisualState: Equatable {
    let centerX: CGFloat
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
}

struct ActiveTabGlassAppearance: Equatable {
    static let standard = ActiveTabGlassAppearance(
        tintRed: 0.88,
        tintGreen: 0.20,
        tintBlue: 0.32,
        tintOpacity: 0.14,
        iconRed: 0.88,
        iconGreen: 0.20,
        iconBlue: 0.32,
        glassOpacity: 1,
        saturation: 1,
        highlightOpacity: 0.52
    )

    let tintRed: Double
    let tintGreen: Double
    let tintBlue: Double
    let tintOpacity: Double
    let iconRed: Double
    let iconGreen: Double
    let iconBlue: Double
    let glassOpacity: Double
    let saturation: Double
    let highlightOpacity: Double

    var tintColor: Color {
        Color(red: tintRed, green: tintGreen, blue: tintBlue)
    }

    var iconColor: Color {
        Color(red: iconRed, green: iconGreen, blue: iconBlue)
    }
}

struct ActiveTabGlassStyle: ViewModifier {
    let cornerRadius: CGFloat
    let appearance: ActiveTabGlassAppearance

    @ViewBuilder
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(
            cornerRadius: cornerRadius,
            style: .continuous
        )

        if #available(iOS 26.0, *) {
            content
                .glassEffect(
                    .regular
                        .tint(appearance.tintColor.opacity(appearance.tintOpacity))
                        .interactive(),
                    in: .rect(cornerRadius: cornerRadius)
                )
                .overlay {
                    shape.stroke(
                        .white.opacity(appearance.highlightOpacity),
                        lineWidth: 0.8
                    )
                }
                .opacity(appearance.glassOpacity)
                .saturation(appearance.saturation)
                .shadow(
                    color: appearance.tintColor.opacity(0.10),
                    radius: 6,
                    y: 2
                )
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape.fill(
                        appearance.tintColor.opacity(appearance.tintOpacity)
                    )
                }
                .overlay {
                    shape.stroke(
                        .white.opacity(appearance.highlightOpacity),
                        lineWidth: 0.8
                    )
                }
                .opacity(appearance.glassOpacity)
                .saturation(appearance.saturation)
                .shadow(
                    color: appearance.tintColor.opacity(0.10),
                    radius: 6,
                    y: 2
                )
        }
    }
}

struct TabBarAnimationModel {
    static let collapsedDiameter: CGFloat = 54
    static let expandedHeight: CGFloat = 68
    static let horizontalInset: CGFloat = 8

    let progress: CGFloat
    let selectedTab: AppTab

    private var clampedProgress: CGFloat {
        min(max(progress, 0), 1)
    }

    var leadingEdge: CGFloat { 0 }

    var collapsedTabIdentifier: String {
        "collapsed-tab-\(selectedTab.rawValue)"
    }

    var activeAppearance: ActiveTabGlassAppearance {
        .standard
    }

    func containerSize(expandedWidth: CGFloat) -> CGSize {
        CGSize(
            width: interpolate(
                expandedWidth,
                0,
                by: clampedProgress
            ),
            height: interpolate(
                Self.expandedHeight,
                0,
                by: clampedProgress
            )
        )
    }

    func activeState(expandedWidth: CGFloat) -> TabBarActiveVisualState {
        let expandedSlotWidth = slotWidth(expandedWidth: expandedWidth)

        return TabBarActiveVisualState(
            centerX: interpolate(
                centerX(for: selectedTab, expandedWidth: expandedWidth),
                Self.collapsedDiameter / 2,
                by: clampedProgress
            ),
            width: interpolate(
                min(expandedSlotWidth, 68),
                Self.collapsedDiameter,
                by: clampedProgress
            ),
            height: Self.collapsedDiameter,
            cornerRadius: Self.collapsedDiameter / 2
        )
    }

    func inactiveState(
        for tab: AppTab,
        expandedWidth: CGFloat
    ) -> TabBarInactiveVisualState {
        let expandedFraction = 1 - clampedProgress
        let reveal = smoothstep(
            normalize(expandedFraction, lower: 0.5, upper: 0.75)
        )

        return TabBarInactiveVisualState(
            centerX: centerX(for: tab, expandedWidth: expandedWidth),
            opacity: Double(reveal),
            scale: interpolate(0.92, 1, by: reveal),
            isInteractive: reveal > 0.98
        )
    }

    private func interpolate(_ start: CGFloat, _ end: CGFloat, by value: CGFloat) -> CGFloat {
        start + (end - start) * value
    }

    private func slotWidth(expandedWidth: CGFloat) -> CGFloat {
        max(expandedWidth - Self.horizontalInset * 2, 0)
            / CGFloat(AppTab.allCases.count)
    }

    private func centerX(for tab: AppTab, expandedWidth: CGFloat) -> CGFloat {
        let index = CGFloat(AppTab.allCases.firstIndex(of: tab) ?? 0)
        return Self.horizontalInset + slotWidth(expandedWidth: expandedWidth) * (index + 0.5)
    }

    private func normalize(
        _ value: CGFloat,
        lower: CGFloat,
        upper: CGFloat
    ) -> CGFloat {
        guard upper > lower else { return value >= upper ? 1 : 0 }
        return min(max((value - lower) / (upper - lower), 0), 1)
    }

    private func smoothstep(_ value: CGFloat) -> CGFloat {
        value * value * (3 - 2 * value)
    }
}

struct FloatingTabBar: View {
    @Binding var selection: AppTab
    @Binding var isCollapsed: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var collapseProgress: CGFloat = 0

    private let barHeight: CGFloat = 68
    private let horizontalMargin: CGFloat = 16
    private let selectionSpring = Animation.spring(
        response: 0.30,
        dampingFraction: 0.88,
        blendDuration: 0.08
    )
    private let geometrySpring = Animation.spring(
        response: 0.36,
        dampingFraction: 0.88,
        blendDuration: 0.08
    )

    var body: some View {
        GeometryReader { geometry in
            let expandedWidth = max(
                geometry.size.width - horizontalMargin * 2,
                TabBarAnimationModel.collapsedDiameter
            )

            navigationSurface(expandedWidth: expandedWidth)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(height: barHeight)
        .onAppear {
            collapseProgress = isCollapsed ? 1 : 0
        }
        .onChange(of: isCollapsed) { _, collapsed in
            animateCollapse(to: collapsed)
        }
        .animation(selectionSpring, value: selection)
    }

    private func navigationSurface(expandedWidth: CGFloat) -> some View {
        let model = TabBarAnimationModel(
            progress: collapseProgress,
            selectedTab: selection
        )

        return ZStack(alignment: .leading) {
            glassSurface(model: model, expandedWidth: expandedWidth)
                .zIndex(0)
            inactiveButtons(model: model, expandedWidth: expandedWidth)
                .zIndex(1)
            activeButton(model: model, expandedWidth: expandedWidth)
                .zIndex(2)
        }
        .frame(maxWidth: .infinity, minHeight: barHeight, alignment: .leading)
        .padding(.leading, horizontalMargin)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(isCollapsed ? "tab-bar-collapsed" : "tab-bar-expanded")
    }

    private func glassSurface(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat
    ) -> some View {
        let size = model.containerSize(expandedWidth: expandedWidth)
        let cornerRadius = max(size.height / 2, 1)
        let shape = RoundedRectangle(
            cornerRadius: cornerRadius,
            style: .continuous
        )

        return shape
            .fill(.clear)
            .frame(width: size.width, height: size.height)
            .overlay {
                shape.stroke(.white.opacity(0.22), lineWidth: 0.7)
            }
            .glassPanel(cornerRadius: cornerRadius)
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .frame(height: barHeight)
            .allowsHitTesting(false)
    }

    private func inactiveButtons(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat
    ) -> some View {
        ZStack(alignment: .leading) {
            ForEach(AppTab.allCases.filter { $0 != selection }) { tab in
                inactiveButton(
                    tab,
                    model: model,
                    expandedWidth: expandedWidth
                )
            }
        }
        .frame(width: expandedWidth, height: barHeight, alignment: .leading)
        .allowsHitTesting(!isCollapsed)
    }

    private func inactiveButton(
        _ tab: AppTab,
        model: TabBarAnimationModel,
        expandedWidth: CGFloat
    ) -> some View {
        let state = model.inactiveState(for: tab, expandedWidth: expandedWidth)

        return Button {
            guard !isCollapsed else { return }
            withAnimation(selectionSpring) {
                selection = tab
            }
        } label: {
            AppTabIconView(tab: tab)
                .foregroundStyle(Color.primary.opacity(0.72))
                .frame(width: 54, height: 54)
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .position(x: state.centerX, y: barHeight / 2)
        .opacity(state.opacity)
        .scaleEffect(reduceMotion ? 1 : state.scale)
        .allowsHitTesting(state.isInteractive && !isCollapsed)
        .disabled(isCollapsed || !state.isInteractive)
        .accessibilityHidden(isCollapsed || state.opacity < 0.98)
        .accessibilityLabel(tab.title)
        .accessibilityIdentifier("tab-\(tab.rawValue)")
    }

    private func activeButton(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat
    ) -> some View {
        let state = model.activeState(expandedWidth: expandedWidth)
        let appearance = model.activeAppearance
        let shape = RoundedRectangle(
            cornerRadius: state.cornerRadius,
            style: .continuous
        )

        return Button {
            if isCollapsed {
                isCollapsed = false
            }
        } label: {
            AppTabIconView(tab: selection)
                .foregroundStyle(appearance.iconColor)
                .frame(width: state.width, height: state.height)
                .modifier(
                    ActiveTabGlassStyle(
                        cornerRadius: state.cornerRadius,
                        appearance: appearance
                    )
                )
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .position(x: state.centerX, y: barHeight / 2)
        .accessibilityLabel(
            isCollapsed
                ? "展开导航栏，当前页面：\(selection.title)"
                : selection.title
        )
        .accessibilityValue("single-active-control")
        .accessibilityIdentifier(
            isCollapsed
                ? model.collapsedTabIdentifier
                : "tab-\(selection.rawValue)"
        )
    }

    private func animateCollapse(to collapsed: Bool) {
        let target: CGFloat = collapsed ? 1 : 0
        let animation = reduceMotion
            ? Animation.easeOut(duration: 0.16)
            : geometrySpring

        withAnimation(animation) {
            collapseProgress = target
        }
    }
}

struct AppTabIconView: View {
    let tab: AppTab

    @ViewBuilder
    var body: some View {
        switch tab.icon {
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: tab == .calendar ? 27 : 25, weight: .medium))
                .symbolVariant(.none)
        case .asset(let name):
            Image(name)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 29, height: 29)
        }
    }
}
