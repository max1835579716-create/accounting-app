import SwiftUI

struct BrandedScreenBackground<Content: View>: View {
    @ViewBuilder private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            AppTheme.Gradients.warmSurface
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            content()
        }
    }
}

struct BrandedCard<Content: View>: View {
    private let padding: CGFloat
    @ViewBuilder private let content: () -> Content

    init(
        padding: CGFloat = AppTheme.Spacing.md,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.content = content
    }

    var body: some View {
        let shadow = AppTheme.Shadows.card

        content()
            .padding(padding)
            .background(AppTheme.Colors.surfaceSoft)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                    .stroke(AppTheme.Colors.outline.opacity(0.72), lineWidth: 0.8)
                    .allowsHitTesting(false)
            }
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}

struct BrandedSectionHeader: View {
    let title: String
    var action: String?

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "pawprint.fill")
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.accentOrange)
                .accessibilityHidden(true)

            Text(title)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Spacer(minLength: AppTheme.Spacing.sm)

            if let action {
                Text(action)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
    }
}

struct BrandedIconTile: View {
    let systemName: String
    var tint: Color = AppTheme.Colors.accentOrange
    var background: Color = AppTheme.Colors.surfacePeach

    var body: some View {
        Image(systemName: systemName)
            .font(.title3.weight(.semibold))
            .foregroundStyle(tint)
            .frame(
                width: AppTheme.Layout.minimumTapTarget,
                height: AppTheme.Layout.minimumTapTarget
            )
            .background(
                background,
                in: RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}

enum MascotDecorationSize {
    case cardCorner
    case header

    var dimension: CGFloat {
        switch self {
        case .cardCorner:
            AppTheme.Layout.mascotCardCornerMaxHeight
        case .header:
            AppTheme.Layout.mascotHeaderMaxHeight
        }
    }
}

/// Non-interactive placeholder used until approved transparent mascot assets exist.
struct MascotDecoration: View {
    var size: MascotDecorationSize = .cardCorner

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.surfacePeach)

            Circle()
                .stroke(AppTheme.Colors.outline, lineWidth: 1)

            Image(systemName: "pawprint.fill")
                .font(.system(size: size.dimension * 0.34, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.accentOrange.opacity(0.62))
        }
        .frame(width: size.dimension, height: size.dimension)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview("Brand Foundation") {
    BrandedScreenBackground {
        VStack(spacing: AppTheme.Spacing.sectionVertical) {
            BrandedSectionHeader(title: "日常管理", action: "查看全部")

            BrandedCard {
                HStack(spacing: AppTheme.Spacing.md) {
                    BrandedIconTile(systemName: "creditcard")
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                        Text("品牌卡片")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                        Text("仅用于隔离预览，尚未接入现有页面")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    Spacer()
                    MascotDecoration()
                }
            }
        }
        .padding(AppTheme.Spacing.screenHorizontal)
    }
}
