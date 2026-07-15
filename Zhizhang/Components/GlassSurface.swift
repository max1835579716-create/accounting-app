import SwiftUI

extension View {
    @ViewBuilder
    func glassPanel(cornerRadius: CGFloat = 24, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(.white.opacity(0.55), lineWidth: 0.8)
                }
        }
    }

    @ViewBuilder
    func glassCircle(interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.interactive(), in: .circle)
            } else {
                self.glassEffect(.regular, in: .circle)
            }
        } else {
            self.background(.ultraThinMaterial, in: Circle())
                .overlay { Circle().stroke(.white.opacity(0.6), lineWidth: 0.8) }
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

enum TabBarVisibility: Equatable {
    case expanded
    case collapsed

    var isCollapsed: Bool {
        self == .collapsed
    }
}

struct TabBarScrollBehavior {
    var visibility: TabBarVisibility = .expanded

    private var lastOffset: CGFloat?
    private var downwardDistance: CGFloat = 0
    private var upwardDistance: CGFloat = 0

    private let collapseThreshold: CGFloat = 20
    private let expandThreshold: CGFloat = 16
    private let topResetOffset: CGFloat = -8

    mutating func update(
        offset: CGFloat,
        allowTransition: Bool = true
    ) -> TabBarVisibility {
        // Positive values are elastic top overscroll, not downward browsing.
        let clampedOffset = min(offset, 0)
        defer { lastOffset = clampedOffset }

        guard let lastOffset else {
            return visibility
        }

        guard allowTransition else {
            resetAccumulatedDistance()
            return visibility
        }

        if clampedOffset >= topResetOffset {
            visibility = .expanded
            resetAccumulatedDistance()
            return visibility
        }

        let delta = clampedOffset - lastOffset

        if delta < 0 {
            downwardDistance += abs(delta)
            upwardDistance = 0

            if clampedOffset <= -collapseThreshold,
               downwardDistance >= collapseThreshold {
                visibility = .collapsed
                resetAccumulatedDistance()
            }
        } else {
            upwardDistance += delta
            downwardDistance = 0

            if upwardDistance >= expandThreshold {
                visibility = .expanded
                resetAccumulatedDistance()
            }
        }

        return visibility
    }

    private mutating func resetAccumulatedDistance() {
        downwardDistance = 0
        upwardDistance = 0
    }
}

struct CollapsingScrollView<Content: View>: View {
    @Binding var isCollapsed: Bool
    @State private var scrollBehavior = TabBarScrollBehavior()
    @State private var isTransitionLocked = false
    @State private var unlockTask: Task<Void, Never>?
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                modernTrackedScrollView
            } else {
                legacyTrackedScrollView
            }
        }
        .onDisappear {
            unlockTask?.cancel()
        }
    }

    @available(iOS 18.0, *)
    private var modernTrackedScrollView: some View {
        ScrollView(showsIndicators: false) {
            content()
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, offset in
            updateVisibility(offset: -offset)
        }
    }

    private var legacyTrackedScrollView: some View {
        ScrollView(showsIndicators: false) {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ScrollOffsetKey.self,
                    value: proxy.frame(in: .named("zhizhang-scroll")).minY
                )
            }
            .frame(height: 0)

            content()
        }
        .coordinateSpace(name: "zhizhang-scroll")
        .onPreferenceChange(ScrollOffsetKey.self) { offset in
            updateVisibility(offset: offset)
        }
    }

    private func updateVisibility(offset: CGFloat) {
        let visibility = scrollBehavior.update(
            offset: offset,
            allowTransition: !isTransitionLocked
        )
        guard isCollapsed != visibility.isCollapsed else {
            return
        }

        isTransitionLocked = true
        isCollapsed = visibility.isCollapsed

        unlockTask?.cancel()
        unlockTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            isTransitionLocked = false
        }
    }
}

struct SectionHeader: View {
    let title: String
    var action: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
            Spacer()
            if let action {
                Text(action)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

extension Double {
    var currencyText: String {
        let amount = formatted(.number.grouping(.automatic).precision(.fractionLength(self.rounded() == self ? 0 : 2)))
        return "¥\(amount)"
    }
}
