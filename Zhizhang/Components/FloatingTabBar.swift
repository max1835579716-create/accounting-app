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
        tintOpacity: 0.08,
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
                .overlay { LiquidTabLensHighlights(shape: shape, appearance: appearance) }
                .opacity(appearance.glassOpacity)
                .saturation(appearance.saturation)
                .shadow(
                    color: appearance.tintColor.opacity(0.10),
                    radius: 10,
                    y: 4
                )
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay { LiquidTabLensFallbackTint(shape: shape, appearance: appearance) }
                .overlay { LiquidTabLensHighlights(shape: shape, appearance: appearance) }
                .opacity(appearance.glassOpacity)
                .saturation(appearance.saturation)
                .shadow(
                    color: appearance.tintColor.opacity(0.10),
                    radius: 10,
                    y: 4
                )
        }
    }
}

private struct ExpandedLiquidLensGlassStyle: ViewModifier {
    let cornerRadius: CGFloat
    let appearance: ActiveTabGlassAppearance

    @ViewBuilder
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if #available(iOS 26.0, *) {
            content
                .glassEffect(
                    .regular
                        .tint(appearance.tintColor.opacity(appearance.tintOpacity))
                        .interactive(),
                    in: .rect(cornerRadius: cornerRadius)
                )
                .opacity(appearance.glassOpacity)
                .saturation(appearance.saturation)
                .shadow(
                    color: .black.opacity(0.09),
                    radius: 8,
                    y: 3
                )
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape.fill(
                        appearance.tintColor.opacity(appearance.tintOpacity)
                    )
                }
                .opacity(appearance.glassOpacity)
                .saturation(appearance.saturation)
                .shadow(
                    color: .black.opacity(0.09),
                    radius: 8,
                    y: 3
                )
        }
    }
}

private struct ExpandedLiquidLensOpticalEdge<S: InsettableShape>: View {
    let shape: S
    let direction: CGFloat
    let stretch: CGFloat

    private var lightStart: UnitPoint {
        direction < -0.08 ? .topTrailing : .topLeading
    }

    private var lightEnd: UnitPoint {
        direction < -0.08 ? .bottomLeading : .bottomTrailing
    }

    var body: some View {
        ZStack {
            shape
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.26 + Double(stretch) * 0.08),
                            .white.opacity(0.08),
                            .clear,
                            .white.opacity(0.14)
                        ],
                        startPoint: lightStart,
                        endPoint: lightEnd
                    ),
                    lineWidth: 0.7
                )
                .blendMode(.screen)

            shape
                .inset(by: 0.8)
                .stroke(
                    LinearGradient(
                        colors: [
                            .clear,
                            .black.opacity(0.045 + Double(stretch) * 0.025)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.55
                )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct LiquidTabLensHighlights<S: Shape>: View {
    let shape: S
    let appearance: ActiveTabGlassAppearance

    var body: some View {
        ZStack(alignment: .topLeading) {
            shape
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(appearance.highlightOpacity + 0.18),
                            .white.opacity(0.16),
                            appearance.tintColor.opacity(0.20),
                            .white.opacity(0.36)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.1
                )

            VStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.68),
                                .white.opacity(0.14),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 28, height: 5)
                    .padding(.top, 8)
                    .padding(.leading, 14)
                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(.white.opacity(0.20))
                        .frame(width: 9, height: 9)
                        .blur(radius: 0.4)
                        .padding(10)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct LiquidTabLensFallbackTint<S: Shape>: View {
    let shape: S
    let appearance: ActiveTabGlassAppearance

    var body: some View {
        shape
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(0.20),
                        appearance.tintColor.opacity(appearance.tintOpacity),
                        .white.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
    }
}

struct LiquidTabIconVisualState: Equatable {
    let influence: CGFloat
    let scale: CGFloat
    let offsetY: CGFloat
    let brightness: Double
}

struct LiquidTabIconVisualModel {
    static func state(
        tabCenterX: CGFloat,
        lensEdges: LiquidLensEdges,
        baseWidth: CGFloat,
        reduceMotion: Bool
    ) -> LiquidTabIconVisualState {
        let falloffRadius = max(baseWidth * 0.78, lensEdges.width * 0.58, 1)
        let distance = abs(tabCenterX - lensEdges.centerX)
        let linearInfluence = min(max(1 - distance / falloffRadius, 0), 1)
        let influence = linearInfluence * linearInfluence * (3 - 2 * linearInfluence)
        let scaleAmount: CGFloat = reduceMotion ? 0.025 : 0.075
        let offsetAmount: CGFloat = reduceMotion ? 0.5 : 1.25
        let brightnessAmount: Double = reduceMotion ? 0.01 : 0.025

        return LiquidTabIconVisualState(
            influence: influence,
            scale: 1 + influence * scaleAmount,
            offsetY: -influence * offsetAmount,
            brightness: Double(influence) * brightnessAmount
        )
    }
}

private struct LiquidTabIconVisualStyle: ViewModifier {
    let state: LiquidTabIconVisualState
    let appearance: ActiveTabGlassAppearance
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .foregroundStyle(interpolatedColor)
            .scaleEffect(state.scale)
            .offset(y: state.offsetY)
            .brightness(state.brightness)
    }

    private var interpolatedColor: Color {
        let normal = Color.primary.opacity(0.72)
        if #available(iOS 18.0, *) {
            return normal.mix(
                with: appearance.iconColor,
                by: Double(state.influence),
                in: .perceptual
            )
        }

        let influence = Double(state.influence)
        let normalComponent = colorScheme == .dark ? 1.0 : 0.0
        return Color(
            red: normalComponent + (appearance.iconRed - normalComponent) * influence,
            green: normalComponent + (appearance.iconGreen - normalComponent) * influence,
            blue: normalComponent + (appearance.iconBlue - normalComponent) * influence,
            opacity: 0.72 + 0.28 * influence
        )
    }
}

struct LiquidLensEdges: Equatable {
    var minX: CGFloat
    var maxX: CGFloat

    var centerX: CGFloat { (minX + maxX) / 2 }
    var width: CGFloat { max(maxX - minX, 0) }
}

struct LiquidTabGeometry {
    static func progress(for x: CGFloat, centers: [CGFloat]) -> CGFloat {
        guard let first = centers.first else { return 0 }
        guard centers.count > 1 else { return 0 }
        if x <= first { return 0 }
        if let last = centers.last, x >= last {
            return CGFloat(centers.count - 1)
        }

        for index in 0..<(centers.count - 1) {
            let lower = centers[index]
            let upper = centers[index + 1]
            guard x >= lower, x <= upper else { continue }
            let fraction = (x - lower) / max(upper - lower, 1)
            return CGFloat(index) + fraction
        }

        return 0
    }

    static func centerX(for progress: CGFloat, centers: [CGFloat]) -> CGFloat {
        guard let first = centers.first else { return 0 }
        guard centers.count > 1 else { return first }
        let clamped = min(max(progress, 0), CGFloat(centers.count - 1))
        let lowerIndex = min(Int(floor(clamped)), centers.count - 1)
        let upperIndex = min(lowerIndex + 1, centers.count - 1)
        let fraction = clamped - CGFloat(lowerIndex)
        return centers[lowerIndex] + (centers[upperIndex] - centers[lowerIndex]) * fraction
    }

    static func draggedEdges(
        centerX: CGFloat,
        velocityX: CGFloat,
        baseWidth: CGFloat,
        reduceMotion: Bool
    ) -> LiquidLensEdges {
        let speed = min(abs(velocityX) / 800, 1)
        let stretchLimit = reduceMotion ? 0.08 : 0.55
        let stretch = min(baseWidth * stretchLimit * speed, baseWidth * 0.8)
        let frontExtension = stretch * 0.62
        let rearExtension = stretch * 0.38
        let halfWidth = baseWidth / 2

        if velocityX < 0 {
            return LiquidLensEdges(
                minX: centerX - halfWidth - frontExtension,
                maxX: centerX + halfWidth + rearExtension
            )
        }

        return LiquidLensEdges(
            minX: centerX - halfWidth - rearExtension,
            maxX: centerX + halfWidth + frontExtension
        )
    }

    static func releaseTarget(
        progress: CGFloat,
        predictedTranslationRemainder: CGFloat,
        centers: [CGFloat],
        committedIndex: Int,
        exceededDragThreshold: Bool
    ) -> Int {
        guard exceededDragThreshold, !centers.isEmpty else {
            return min(max(committedIndex, 0), max(centers.count - 1, 0))
        }
        let currentCenter = centerX(for: progress, centers: centers)
        let projectedCenter = currentCenter + predictedTranslationRemainder * 0.18
        return Int(Self.progress(for: projectedCenter, centers: centers).rounded())
    }
}

struct LiquidTabSelectionState: Equatable {
    private(set) var committedIndex: Int
    private(set) var selectionProgress: CGFloat
    private(set) var previewIndex: Int
    private var dragStartProgress: CGFloat

    init(committedIndex: Int) {
        self.committedIndex = committedIndex
        selectionProgress = CGFloat(committedIndex)
        previewIndex = committedIndex
        dragStartProgress = CGFloat(committedIndex)
    }

    mutating func beginDrag() {
        dragStartProgress = selectionProgress
    }

    mutating func updateDrag(translationX: CGFloat, centers: [CGFloat]) {
        guard !centers.isEmpty else { return }
        let startCenter = LiquidTabGeometry.centerX(
            for: dragStartProgress,
            centers: centers
        )
        selectionProgress = LiquidTabGeometry.progress(
            for: startCenter + translationX,
            centers: centers
        )
        previewIndex = Int(selectionProgress.rounded())
    }

    mutating func commit(index: Int, preservingPreview: Bool = false) {
        committedIndex = max(index, 0)
        guard !preservingPreview else { return }
        selectionProgress = CGFloat(committedIndex)
        previewIndex = committedIndex
        dragStartProgress = selectionProgress
    }

    mutating func updateAnimation(centerX: CGFloat, centers: [CGFloat]) {
        selectionProgress = LiquidTabGeometry.progress(
            for: centerX,
            centers: centers
        )
        previewIndex = Int(selectionProgress.rounded())
    }
}

struct LiquidLensMotionState: Equatable {
    private(set) var edges: LiquidLensEdges
    private var minVelocity: CGFloat = 0
    private var maxVelocity: CGFloat = 0

    init(centerX: CGFloat, width: CGFloat) {
        edges = LiquidLensEdges(
            minX: centerX - width / 2,
            maxX: centerX + width / 2
        )
    }

    init(edges: LiquidLensEdges) {
        self.edges = edges
    }

    mutating func set(edges: LiquidLensEdges, velocityX: CGFloat) {
        self.edges = edges
        minVelocity = velocityX
        maxVelocity = velocityX
    }

    mutating func step(
        towardCenterX targetCenterX: CGFloat,
        baseWidth: CGFloat,
        deltaTime: CGFloat,
        reduceMotion: Bool
    ) {
        let targetMinX = targetCenterX - baseWidth / 2
        let targetMaxX = targetCenterX + baseWidth / 2
        let direction = targetCenterX - edges.centerX
        let frontFrequency: CGFloat = reduceMotion ? 30 : 27
        let rearFrequency: CGFloat = reduceMotion ? 30 : 22
        let minFrequency = direction < 0 ? frontFrequency : rearFrequency
        let maxFrequency = direction < 0 ? rearFrequency : frontFrequency

        springStep(
            position: &edges.minX,
            velocity: &minVelocity,
            target: targetMinX,
            frequency: minFrequency,
            deltaTime: deltaTime
        )
        springStep(
            position: &edges.maxX,
            velocity: &maxVelocity,
            target: targetMaxX,
            frequency: maxFrequency,
            deltaTime: deltaTime
        )

        let maximumWidth = baseWidth * (reduceMotion ? 1.12 : 1.8)
        if edges.width > maximumWidth {
            if direction < 0 {
                edges.maxX = edges.minX + maximumWidth
                maxVelocity = minVelocity
            } else {
                edges.minX = edges.maxX - maximumWidth
                minVelocity = maxVelocity
            }
        }
    }

    mutating func settle(centerX: CGFloat, width: CGFloat) {
        edges = LiquidLensEdges(
            minX: centerX - width / 2,
            maxX: centerX + width / 2
        )
        minVelocity = 0
        maxVelocity = 0
    }

    private func springStep(
        position: inout CGFloat,
        velocity: inout CGFloat,
        target: CGFloat,
        frequency: CGFloat,
        deltaTime: CGFloat
    ) {
        let acceleration = frequency * frequency * (target - position)
            - 2 * frequency * velocity
        velocity += acceleration * deltaTime
        position += velocity * deltaTime
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

    func slotWidth(expandedWidth: CGFloat) -> CGFloat {
        max(expandedWidth - Self.horizontalInset * 2, 0)
            / CGFloat(AppTab.allCases.count)
    }

    func centerX(for tab: AppTab, expandedWidth: CGFloat) -> CGFloat {
        let index = CGFloat(AppTab.allCases.firstIndex(of: tab) ?? 0)
        return Self.horizontalInset + slotWidth(expandedWidth: expandedWidth) * (index + 0.5)
    }

    func nearestTab(to centerX: CGFloat, expandedWidth: CGFloat) -> AppTab {
        AppTab.allCases.min { first, second in
            abs(self.centerX(for: first, expandedWidth: expandedWidth) - centerX)
                < abs(self.centerX(for: second, expandedWidth: expandedWidth) - centerX)
        } ?? selectedTab
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

private struct LiquidTabCenterPreferenceKey: PreferenceKey {
    static let defaultValue: [AppTab: CGFloat] = [:]

    static func reduce(
        value: inout [AppTab: CGFloat],
        nextValue: () -> [AppTab: CGFloat]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { _, latest in latest })
    }
}

struct FloatingTabBar: View {
    @Binding var selection: AppTab
    @Binding var isCollapsed: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var collapseProgress: CGFloat = 0
    @State private var interaction = LiquidTabSelectionState(committedIndex: 0)
    @State private var lensMotion = LiquidLensMotionState(centerX: 0, width: 54)
    @State private var measuredTabCenters: [AppTab: CGFloat] = [:]
    @State private var lensIsInitialized = false
    @State private var isTrackingGesture = false
    @State private var isDraggingSelection = false
    @State private var exceededDragThreshold = false
    @State private var previousDragTranslation: CGFloat = 0
    @State private var previousDragTime: Date?
    @State private var snapTask: Task<Void, Never>?
    @State private var committedBeforeRelease = false
    @Namespace private var glassNamespace

    private let barHeight: CGFloat = 68
    private let horizontalMargin: CGFloat = 16
    private let dragThreshold: CGFloat = 5
    private let dragCoordinateSpace = "LiquidTabBar"
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
            interaction = LiquidTabSelectionState(committedIndex: selectedIndex)
        }
        .onDisappear {
            snapTask?.cancel()
        }
        .onChange(of: isCollapsed) { _, collapsed in
            handleCollapseChange(collapsed)
        }
        .onChange(of: selection) { _, newSelection in
            if isTrackingGesture {
                committedBeforeRelease = true
            }
            synchronizeExternalSelection(newSelection)
        }
    }

    private func navigationSurface(expandedWidth: CGFloat) -> some View {
        let model = TabBarAnimationModel(
            progress: collapseProgress,
            selectedTab: selection
        )
        let centers = resolvedCenters(model: model, expandedWidth: expandedWidth)
        let baseWidth = model.activeState(expandedWidth: expandedWidth).width
        let edges = displayedEdges(
            centers: centers,
            baseWidth: baseWidth
        )

        return ZStack(alignment: .leading) {
            if isCollapsed {
                glassSurface(model: model, expandedWidth: expandedWidth)
                    .zIndex(0)
                collapsedInactiveButtons(model: model, expandedWidth: expandedWidth)
                    .zIndex(1)
                collapsedActiveLens(model: model, expandedWidth: expandedWidth)
                    .zIndex(2)
                collapsedActiveButton(model: model, expandedWidth: expandedWidth)
                    .zIndex(3)
            } else {
                expandedNavigationLayers(
                    model: model,
                    expandedWidth: expandedWidth,
                    centers: centers,
                    baseWidth: baseWidth,
                    edges: edges
                )
            }
        }
        .frame(width: expandedWidth, height: barHeight, alignment: .leading)
        .contentShape(Rectangle())
        .coordinateSpace(name: dragCoordinateSpace)
        .highPriorityGesture(
            tabDragGesture(centers: centers, baseWidth: baseWidth),
            including: isCollapsed ? .none : .all
        )
        .simultaneousGesture(
            TapGesture().onEnded {
                expandCollapsedBar()
            },
            including: isCollapsed ? .all : .none
        )
        .onPreferenceChange(LiquidTabCenterPreferenceKey.self) { centers in
            updateMeasuredCenters(centers, baseWidth: baseWidth)
        }
        .padding(.leading, horizontalMargin)
        .frame(maxWidth: .infinity, minHeight: barHeight, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(isCollapsed ? "tab-bar-collapsed" : "tab-bar-expanded")
        .accessibilityValue(interactionAccessibilityValue)
    }

    private func expandedNavigationLayers(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat,
        centers: [CGFloat],
        baseWidth: CGFloat,
        edges: LiquidLensEdges
    ) -> some View {
        ZStack(alignment: .leading) {
            expandedGlassLayers(
                model: model,
                expandedWidth: expandedWidth,
                baseWidth: baseWidth,
                edges: edges
            )
            .zIndex(1)

            tabContentLayer(
                expandedWidth: expandedWidth,
                centers: centers,
                edges: edges,
                baseWidth: baseWidth,
                appearance: model.activeAppearance
            )
            .zIndex(2)

            expandedLiquidLensEdge(
                edges: edges,
                baseWidth: baseWidth,
                centers: centers
            )
            .zIndex(3)

            accessibilityInteractionLayer(
                expandedWidth: expandedWidth,
                centers: centers,
                baseWidth: baseWidth
            )
            .zIndex(4)
        }
    }

    @ViewBuilder
    private func expandedGlassLayers(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat,
        baseWidth: CGFloat,
        edges: LiquidLensEdges
    ) -> some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 8) {
                expandedGlassLayerStack(
                    model: model,
                    expandedWidth: expandedWidth,
                    baseWidth: baseWidth,
                    edges: edges
                )
            }
        } else {
            expandedGlassLayerStack(
                model: model,
                expandedWidth: expandedWidth,
                baseWidth: baseWidth,
                edges: edges
            )
        }
    }

    private func expandedGlassLayerStack(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat,
        baseWidth: CGFloat,
        edges: LiquidLensEdges
    ) -> some View {
        ZStack(alignment: .leading) {
            glassSurface(model: model, expandedWidth: expandedWidth)
                .zIndex(0)
            expandedLiquidLens(
                edges: edges,
                baseWidth: baseWidth,
                appearance: model.activeAppearance
            )
            .zIndex(1)
        }
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

    private func expandedLiquidLens(
        edges: LiquidLensEdges,
        baseWidth: CGFloat,
        appearance: ActiveTabGlassAppearance
    ) -> some View {
        let height = lensHeight(edges: edges, baseWidth: baseWidth)
        let cornerRadius = height / 2
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return identifiedExpandedLens(
            shape
                .fill(.clear)
                .frame(width: edges.width, height: height)
                .modifier(
                    ExpandedLiquidLensGlassStyle(
                        cornerRadius: cornerRadius,
                        appearance: appearance
                    )
                )
        )
            .position(x: edges.centerX, y: barHeight / 2)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private func expandedLiquidLensEdge(
        edges: LiquidLensEdges,
        baseWidth: CGFloat,
        centers: [CGFloat]
    ) -> some View {
        let height = lensHeight(edges: edges, baseWidth: baseWidth)
        let shape = RoundedRectangle(cornerRadius: height / 2, style: .continuous)
        let progressCenterX = LiquidTabGeometry.centerX(
            for: interaction.selectionProgress,
            centers: centers
        )
        let direction = min(max((edges.centerX - progressCenterX) / max(baseWidth, 1), -1), 1)
        let stretch = min(max(edges.width / max(baseWidth, 1) - 1, 0), 0.8)

        return ExpandedLiquidLensOpticalEdge(
            shape: shape,
            direction: direction,
            stretch: stretch
        )
        .frame(width: edges.width, height: height)
        .position(x: edges.centerX, y: barHeight / 2)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func identifiedExpandedLens<Content: View>(
        _ content: Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffectID("expanded-liquid-tab-lens", in: glassNamespace)
        } else {
            content
        }
    }

    private func tabContentLayer(
        expandedWidth: CGFloat,
        centers: [CGFloat],
        edges: LiquidLensEdges,
        baseWidth: CGFloat,
        appearance: ActiveTabGlassAppearance
    ) -> some View {
        let contentWidth = max(
            expandedWidth - TabBarAnimationModel.horizontalInset * 2,
            0
        )

        return HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let index = AppTab.allCases.firstIndex(of: tab) ?? 0
                let tabCenterX = centers.indices.contains(index)
                    ? centers[index]
                    : 0
                let visualState = LiquidTabIconVisualModel.state(
                    tabCenterX: tabCenterX,
                    lensEdges: edges,
                    baseWidth: baseWidth,
                    reduceMotion: reduceMotion
                )

                AppTabIconView(tab: tab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .modifier(
                        LiquidTabIconVisualStyle(
                            state: visualState,
                            appearance: appearance
                        )
                    )
                    .background {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: LiquidTabCenterPreferenceKey.self,
                                value: [
                                    tab: geometry.frame(
                                        in: .named(dragCoordinateSpace)
                                    ).midX
                                ]
                            )
                        }
                    }
            }
        }
        .frame(width: contentWidth, height: barHeight)
        .padding(.horizontal, TabBarAnimationModel.horizontalInset)
        .frame(width: expandedWidth, height: barHeight)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func accessibilityInteractionLayer(
        expandedWidth: CGFloat,
        centers: [CGFloat],
        baseWidth: CGFloat
    ) -> some View {
        let contentWidth = max(
            expandedWidth - TabBarAnimationModel.horizontalInset * 2,
            0
        )

        return HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .accessibilityElement()
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(tab.title)
                    .accessibilityValue(
                        tab == selection ? "single-active-control" : ""
                    )
                    .accessibilityIdentifier("tab-\(tab.rawValue)")
                    .accessibilityAction {
                        guard let index = AppTab.allCases.firstIndex(of: tab) else { return }
                        commitTab(
                            at: index,
                            centers: centers,
                            baseWidth: baseWidth
                        )
                    }
            }
        }
        .frame(width: contentWidth, height: barHeight)
        .padding(.horizontal, TabBarAnimationModel.horizontalInset)
        .frame(width: expandedWidth, height: barHeight)
    }

    private func collapsedInactiveButtons(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat
    ) -> some View {
        ZStack(alignment: .leading) {
            ForEach(AppTab.allCases.filter { $0 != selection }) { tab in
                collapsedInactiveButton(
                    tab,
                    model: model,
                    expandedWidth: expandedWidth
                )
            }
        }
        .frame(width: expandedWidth, height: barHeight, alignment: .leading)
        .allowsHitTesting(false)
    }

    private func collapsedInactiveButton(
        _ tab: AppTab,
        model: TabBarAnimationModel,
        expandedWidth: CGFloat
    ) -> some View {
        let state = model.inactiveState(for: tab, expandedWidth: expandedWidth)

        return Button { } label: {
            AppTabIconView(tab: tab)
                .foregroundStyle(Color.primary.opacity(0.72))
                .frame(width: 54, height: 54)
                .contentShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
        }
        .buttonStyle(.plain)
        .position(x: state.centerX, y: barHeight / 2)
        .opacity(state.opacity)
        .scaleEffect(reduceMotion ? 1 : state.scale)
        .allowsHitTesting(state.isInteractive && !isCollapsed)
        .disabled(isCollapsed || !state.isInteractive)
        .accessibilityHidden(isCollapsed || state.opacity < 0.98)
        .accessibilityLabel(tab.title)
        .accessibilityValue("")
        .accessibilityIdentifier("tab-\(tab.rawValue)")
    }

    private func collapsedActiveLens(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat
    ) -> some View {
        let state = model.activeState(expandedWidth: expandedWidth)
        let appearance = model.activeAppearance
        let shape = RoundedRectangle(
            cornerRadius: state.cornerRadius,
            style: .continuous
        )

        return ZStack {
            shape
                .fill(.clear)
                .modifier(
                    ActiveTabGlassStyle(
                        cornerRadius: state.cornerRadius,
                        appearance: appearance
                    )
                )
                .overlay {
                    shape
                        .stroke(.white.opacity(0.28), lineWidth: 0.8)
                        .blur(radius: 0.2)
                }

            AppTabIconView(tab: selection)
                .foregroundStyle(appearance.iconColor)
                .frame(width: 54, height: 54)
        }
        .frame(width: state.width, height: state.height)
        .position(x: state.centerX, y: barHeight / 2)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func collapsedActiveButton(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat
    ) -> some View {
        let state = model.activeState(expandedWidth: expandedWidth)
        let shape = RoundedRectangle(
            cornerRadius: state.cornerRadius,
            style: .continuous
        )

        return Button {
            expandCollapsedBar()
        } label: {
            Rectangle()
                .fill(.white.opacity(0.001))
                .frame(width: state.width, height: state.height)
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityAction {
            expandCollapsedBar()
        }
        .position(x: state.centerX, y: barHeight / 2)
        .accessibilityLabel("展开导航栏，当前页面：\(selection.title)")
        .accessibilityValue("single-active-control")
        .accessibilityIdentifier(model.collapsedTabIdentifier)
    }

    private func tabDragGesture(
        centers: [CGFloat],
        baseWidth: CGFloat
    ) -> some Gesture {
        DragGesture(
            minimumDistance: 0,
            coordinateSpace: .named(dragCoordinateSpace)
        )
        .onChanged { value in
            guard !isCollapsed, centers.count == AppTab.allCases.count else { return }

            if !isTrackingGesture {
                snapTask?.cancel()
                isTrackingGesture = true
                committedBeforeRelease = false
                interaction.beginDrag()
                previousDragTranslation = value.translation.width
                previousDragTime = value.time
            }

            let distance = hypot(value.translation.width, value.translation.height)
            if distance >= dragThreshold {
                exceededDragThreshold = true
                isDraggingSelection = true
            }

            guard isDraggingSelection else { return }

            interaction.updateDrag(
                translationX: value.translation.width,
                centers: centers
            )
            let centerX = LiquidTabGeometry.centerX(
                for: interaction.selectionProgress,
                centers: centers
            )
            let velocityX = dragVelocity(
                currentTranslation: value.translation.width,
                currentTime: value.time
            )
            let edges = LiquidTabGeometry.draggedEdges(
                centerX: centerX,
                velocityX: velocityX,
                baseWidth: baseWidth,
                reduceMotion: reduceMotion
            )
            lensMotion.set(edges: edges, velocityX: velocityX)
            previousDragTranslation = value.translation.width
            previousDragTime = value.time
        }
        .onEnded { value in
            guard !isCollapsed, centers.count == AppTab.allCases.count else {
                finishGestureTracking()
                return
            }

            let targetIndex: Int
            if exceededDragThreshold {
                targetIndex = LiquidTabGeometry.releaseTarget(
                    progress: interaction.selectionProgress,
                    predictedTranslationRemainder: value.predictedEndTranslation.width
                        - value.translation.width,
                    centers: centers,
                    committedIndex: interaction.committedIndex,
                    exceededDragThreshold: true
                )
            } else {
                targetIndex = Int(
                    LiquidTabGeometry.progress(
                        for: value.location.x,
                        centers: centers
                    ).rounded()
                )
            }

            finishGestureTracking()
            commitTab(
                at: targetIndex,
                centers: centers,
                baseWidth: baseWidth
            )
        }
    }

    private func commitTab(
        at index: Int,
        centers: [CGFloat],
        baseWidth: CGFloat
    ) {
        let validIndex = min(max(index, 0), AppTab.allCases.count - 1)
        interaction.commit(index: validIndex, preservingPreview: true)
        selection = AppTab.allCases[validIndex]
        startSnap(
            to: validIndex,
            centers: centers,
            baseWidth: baseWidth
        )
    }

    private func startSnap(
        to index: Int,
        centers: [CGFloat],
        baseWidth: CGFloat
    ) {
        guard centers.indices.contains(index) else { return }
        snapTask?.cancel()
        lensIsInitialized = true
        let targetCenterX = centers[index]
        let frameCount = reduceMotion ? 22 : 42
        let frameDelay: UInt64 = reduceMotion ? 6_000_000 : 8_333_333

        snapTask = Task { @MainActor in
            for _ in 0..<frameCount {
                guard !Task.isCancelled else { return }
                var nextMotion = lensMotion
                nextMotion.step(
                    towardCenterX: targetCenterX,
                    baseWidth: baseWidth,
                    deltaTime: reduceMotion ? 1 / 90 : 1 / 120,
                    reduceMotion: reduceMotion
                )
                lensMotion = nextMotion
                interaction.updateAnimation(
                    centerX: nextMotion.edges.centerX,
                    centers: centers
                )
                try? await Task.sleep(nanoseconds: frameDelay)
            }

            guard !Task.isCancelled else { return }
            lensMotion.settle(centerX: targetCenterX, width: baseWidth)
            interaction.commit(index: index)
        }
    }

    private func updateMeasuredCenters(
        _ centers: [AppTab: CGFloat],
        baseWidth: CGFloat
    ) {
        guard AppTab.allCases.allSatisfy({ centers[$0] != nil }) else { return }
        let changed = AppTab.allCases.contains { tab in
            guard let newCenter = centers[tab] else { return false }
            guard let oldCenter = measuredTabCenters[tab] else { return true }
            return abs(newCenter - oldCenter) > 0.25
        }
        guard changed else { return }

        measuredTabCenters = centers
        guard !isTrackingGesture else { return }

        let orderedCenters = AppTab.allCases.compactMap { centers[$0] }
        guard orderedCenters.indices.contains(selectedIndex) else { return }
        snapTask?.cancel()
        interaction.commit(index: selectedIndex)
        lensMotion.settle(
            centerX: orderedCenters[selectedIndex],
            width: baseWidth
        )
        lensIsInitialized = true
    }

    private func resolvedCenters(
        model: TabBarAnimationModel,
        expandedWidth: CGFloat
    ) -> [CGFloat] {
        let measured = AppTab.allCases.compactMap { measuredTabCenters[$0] }
        guard measured.count == AppTab.allCases.count else {
            return AppTab.allCases.map {
                model.centerX(for: $0, expandedWidth: expandedWidth)
            }
        }
        return measured
    }

    private func displayedEdges(
        centers: [CGFloat],
        baseWidth: CGFloat
    ) -> LiquidLensEdges {
        guard !lensIsInitialized, centers.indices.contains(selectedIndex) else {
            return lensMotion.edges
        }
        let centerX = centers[selectedIndex]
        return LiquidLensEdges(
            minX: centerX - baseWidth / 2,
            maxX: centerX + baseWidth / 2
        )
    }

    private func lensHeight(
        edges: LiquidLensEdges,
        baseWidth: CGFloat
    ) -> CGFloat {
        let stretch = max(edges.width / max(baseWidth, 1) - 1, 0)
        let compression = reduceMotion ? 0 : min(stretch * 0.04, 0.03)
        return TabBarAnimationModel.collapsedDiameter * (1 - compression)
    }

    private func dragVelocity(
        currentTranslation: CGFloat,
        currentTime: Date
    ) -> CGFloat {
        guard let previousDragTime else { return 0 }
        let deltaTime = max(currentTime.timeIntervalSince(previousDragTime), 1 / 240)
        return (currentTranslation - previousDragTranslation) / deltaTime
    }

    private func finishGestureTracking() {
        isTrackingGesture = false
        isDraggingSelection = false
        exceededDragThreshold = false
        previousDragTranslation = 0
        previousDragTime = nil
    }

    private func synchronizeExternalSelection(_ newSelection: AppTab) {
        guard !isTrackingGesture,
              let index = AppTab.allCases.firstIndex(of: newSelection),
              interaction.committedIndex != index else {
            return
        }
        let centers = AppTab.allCases.compactMap { measuredTabCenters[$0] }
        interaction.commit(index: index, preservingPreview: true)
        guard centers.count == AppTab.allCases.count else {
            interaction.commit(index: index)
            return
        }
        let baseWidth = minimumMeasuredSpacing(in: centers)
        startSnap(to: index, centers: centers, baseWidth: min(baseWidth, 68))
    }

    private func handleCollapseChange(_ collapsed: Bool) {
        snapTask?.cancel()
        finishGestureTracking()
        interaction.commit(index: selectedIndex)

        if !collapsed {
            let centers = AppTab.allCases.compactMap { measuredTabCenters[$0] }
            if centers.indices.contains(selectedIndex) {
                lensMotion.settle(
                    centerX: centers[selectedIndex],
                    width: min(minimumMeasuredSpacing(in: centers), 68)
                )
                lensIsInitialized = true
            }
        }

        animateCollapse(to: collapsed)
    }

    private func minimumMeasuredSpacing(in centers: [CGFloat]) -> CGFloat {
        guard centers.count > 1 else { return 54 }
        return zip(centers, centers.dropFirst())
            .map { abs($1 - $0) }
            .min() ?? 54
    }

    private var selectedIndex: Int {
        AppTab.allCases.firstIndex(of: selection) ?? 0
    }

    private var interactionAccessibilityValue: String {
        "committed=\(selection.rawValue);preview=\(interaction.previewIndex);progress=\(interaction.selectionProgress);dragging=\(isDraggingSelection);preReleaseCommit=\(committedBeforeRelease)"
    }

    private func expandCollapsedBar() {
        guard isCollapsed else { return }
        withAnimation(geometrySpring) {
            isCollapsed = false
        }
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
