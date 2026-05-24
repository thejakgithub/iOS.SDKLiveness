//
//  CircleIconView.swift
//  SDK Liveness
//

import SwiftUI

/// Reusable circle icon used in result screens (✓, ✕, ⏰, ⚠)
struct CircleIconView: View {
    let systemName: String
    let color: Color
    let backgroundColor: Color
    let size: CGFloat

    init(
        systemName: String,
        color: Color,
        backgroundColor: Color? = nil,
        size: CGFloat = AppTheme.Size.resultIconSize
    ) {
        self.systemName = systemName
        self.color = color
        self.backgroundColor = backgroundColor ?? color.opacity(0.15)
        self.size = size
    }

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(color, lineWidth: 3)
                .frame(width: size, height: size)

            // Background fill
            Circle()
                .fill(backgroundColor)
                .frame(width: size - 20, height: size - 20)

            // Icon
            Image(systemName: systemName)
                .font(.system(size: size * 0.3, weight: .bold))
                .foregroundColor(color)
        }
    }
}
