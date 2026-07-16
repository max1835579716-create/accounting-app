import SwiftUI

/// Read-only visual parameters for the branded floating tab bar.
enum BrandedTabBarStyle {
    enum Capsule {
        static let fill = AppTheme.Colors.surfaceSoft.opacity(0.86)
        static let tint = AppTheme.Colors.surfacePeach
        static let tintOpacity: Double = 0.13
        static let opacity: Double = 0.98
        static let saturation: Double = 0.91
        static let outline = Color.white.opacity(0.76)
        static let highlight = Color.white.opacity(0.74)
        static let lowerEdge = AppTheme.Colors.outline.opacity(0.55)
        static let outlineWidth: CGFloat = 0.9
        static let shadow = AppTheme.ShadowStyle(
            color: AppTheme.Colors.accentBrown.opacity(0.10),
            radius: 12,
            x: 0,
            y: 5
        )
    }

    enum Selection {
        static let red: Double = 247 / 255
        static let green: Double = 147 / 255
        static let blue: Double = 60 / 255
        static let tint = AppTheme.Colors.accentOrange
        static let fill = AppTheme.Colors.surfacePeach.opacity(0.78)
        static let tintOpacity: Double = 0.10
        static let glassOpacity: Double = 0.98
        static let saturation: Double = 0.96
        static let highlight = Color.white
        static let highlightOpacity: Double = 0.52
        static let lowerEdge = AppTheme.Colors.accentOrangeDeep.opacity(0.22)
        static let shadow = AppTheme.ShadowStyle(
            color: AppTheme.Colors.accentOrange.opacity(0.12),
            radius: 8,
            x: 0,
            y: 3
        )
    }

    enum Item {
        static let inactiveRed: Double = 59 / 255
        static let inactiveGreen: Double = 36 / 255
        static let inactiveBlue: Double = 24 / 255
        static let inactiveOpacity: Double = 0.82
        static let inactive = AppTheme.Colors.textPrimary.opacity(inactiveOpacity)
        static let active = AppTheme.Colors.accentOrange
        static let labelFont = Font.system(.caption2, design: .rounded, weight: .semibold)
        static let labelSpacing: CGFloat = 2
    }

    enum CenterAction {
        static let fill = AppTheme.Gradients.primary
        static let icon = Color.white
        static let ring = Color.white.opacity(0.95)
        static let ringWidth: CGFloat = 1.2
        static let shadow = AppTheme.ShadowStyle(
            color: AppTheme.Colors.accentOrange.opacity(0.20),
            radius: 8,
            x: 0,
            y: 3
        )
    }
}
