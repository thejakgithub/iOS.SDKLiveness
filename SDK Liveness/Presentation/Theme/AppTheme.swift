//
//  AppTheme.swift
//  SDK Liveness
//

import SwiftUI

enum AppTheme {
    // MARK: - Typography
    enum Font {
        static let largeTitle = SwiftUI.Font.system(size: 28, weight: .bold)
        static let title = SwiftUI.Font.system(size: 22, weight: .bold)
        static let headline = SwiftUI.Font.system(size: 18, weight: .semibold)
        static let body = SwiftUI.Font.system(size: 16, weight: .regular)
        static let subheadline = SwiftUI.Font.system(size: 14, weight: .regular)
        static let caption = SwiftUI.Font.system(size: 12, weight: .regular)
        static let bannerTitle = SwiftUI.Font.system(size: 20, weight: .bold)
        static let bannerSubtitle = SwiftUI.Font.system(size: 14, weight: .regular)
        static let buttonTitle = SwiftUI.Font.system(size: 16, weight: .bold)
        static let versionText = SwiftUI.Font.system(size: 13, weight: .regular)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let circle: CGFloat = 999
    }

    // MARK: - Sizes
    enum Size {
        static let splashLogoSize: CGFloat = 160
        static let permissionIconSize: CGFloat = 120
        static let resultIconSize: CGFloat = 160
        static let faceOvalWidth: CGFloat = 220
        static let faceOvalHeight: CGFloat = 300
        static let progressBarHeight: CGFloat = 6
        static let bannerHeight: CGFloat = 80
        static let actionArrowSize: CGFloat = 40
    }
}
