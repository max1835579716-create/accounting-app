import SwiftUI

/// Shared visual tokens for the branded bookkeeping interface.
///
/// These values intentionally remain independent from app state so the visual
/// system can be introduced without changing navigation or business behavior.
enum AppTheme {
    enum Colors {
        static let background = Color(hex: 0xFBF7F2)
        static let backgroundWarm = Color(hex: 0xFFF8EF)
        static let surface = Color(hex: 0xFFFFFF)
        static let surfaceSoft = Color(hex: 0xFFFDF9)
        static let surfacePeach = Color(hex: 0xFFF1E4)
        static let surfaceBlue = Color(hex: 0xEDF6FF)
        static let surfaceRose = Color(hex: 0xFFF0F3)

        static let textPrimary = Color(hex: 0x3B2418)
        static let textSecondary = Color(hex: 0x8C8078)
        static let textTertiary = Color(hex: 0xB5AAA3)

        static let accentOrange = Color(hex: 0xF7933C)
        static let accentOrangeDeep = Color(hex: 0xD96B22)
        static let accentAmber = Color(hex: 0xF4B548)
        static let accentBrown = Color(hex: 0x5A3424)
        static let accentBlue = Color(hex: 0x58A7E6)
        static let accentTeal = Color(hex: 0x39AFC1)
        static let accentCoral = Color(hex: 0xE95472)

        static let positive = Color(hex: 0x36B968)
        static let negative = Color(hex: 0xE64848)
        static let divider = Color(hex: 0xEEE5DD)
        static let outline = Color(hex: 0xF0D7C4)
        static let tabInactive = Color(hex: 0x66615D)
        static let scrim = Color(hex: 0x3B2418, opacity: 0.08)
    }

    /// Financial colors keep their meaning separate from decorative brand colors.
    enum FinancialColors {
        static let income = Colors.positive
        static let expense = Colors.negative
        static let balance = Colors.accentBlue
        static let budgetWarning = Colors.accentAmber
    }

    enum Gradients {
        static let primary = LinearGradient(
            colors: [Color(hex: 0xFFB663), Color(hex: 0xF4832E)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let warmSurface = LinearGradient(
            colors: [Color(hex: 0xFFFDF9), Color(hex: 0xFFF5E9)],
            startPoint: .top,
            endPoint: .bottom
        )
        static let blue = LinearGradient(
            colors: [Color(hex: 0x75BFF0), Color(hex: 0x469CE1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let rose = LinearGradient(
            colors: [Color(hex: 0xF38AA0), Color(hex: 0xE95472)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let screenHorizontal: CGFloat = 20
        static let sectionVertical: CGFloat = 24
    }

    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 18
        static let large: CGFloat = 24
        static let card: CGFloat = 28
        static let pill: CGFloat = 999
    }

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    enum Shadows {
        static let card = ShadowStyle(
            color: Color(hex: 0x6E4524, opacity: 0.08),
            radius: 24,
            x: 0,
            y: 8
        )
        static let floating = ShadowStyle(
            color: Color(hex: 0x7A4A22, opacity: 0.14),
            radius: 32,
            x: 0,
            y: 12
        )
    }

    /// System text styles preserve Dynamic Type while matching the token roles.
    enum Typography {
        static let largeTitle = Font.system(.largeTitle, design: .default, weight: .bold)
        static let title1 = Font.system(.title, design: .default, weight: .bold)
        static let title2 = Font.system(.title2, design: .default, weight: .semibold)
        static let headline = Font.system(.headline, design: .default, weight: .semibold)
        static let body = Font.system(.body, design: .default, weight: .regular)
        static let subheadline = Font.system(.subheadline, design: .default, weight: .regular)
        static let caption = Font.system(.caption, design: .default, weight: .regular)
        static let amountLarge = Font.system(.title, design: .rounded, weight: .bold).monospacedDigit()
        static let amountMedium = Font.system(.title2, design: .rounded, weight: .semibold).monospacedDigit()
    }

    enum Layout {
        static let minimumTapTarget: CGFloat = 44
        static let tabBarHeightApprox: CGFloat = 82
        static let mascotHeaderMaxHeight: CGFloat = 104
        static let mascotCardCornerMaxHeight: CGFloat = 72
        static let contentMaxDecorationOpacity: Double = 0.16
    }
}

private extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
