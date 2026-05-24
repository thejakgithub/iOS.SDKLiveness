//
//  StatusBannerView.swift
//  SDK Liveness
//

import SwiftUI

/// Status banner displayed below the camera view — "Face Detected ✓", "Turn Left ←", etc.
struct StatusBannerView: View {
  let title: String
  let subtitle: String
  let color: Color
  let icon: String?

  init(title: String, subtitle: String, color: Color, icon: String? = nil) {
    self.title = title
    self.subtitle = subtitle
    self.color = color
    self.icon = icon
  }

  var body: some View {
    VStack(spacing: AppTheme.Spacing.xs) {
      HStack(spacing: AppTheme.Spacing.sm) {
        if let icon = icon {
          Text(icon)
            .font(.system(size: 18))
        }

        Text(title)
          .font(AppTheme.Font.bannerTitle)
          .foregroundColor(color)
      }

      Text(subtitle)
        .font(AppTheme.Font.bannerSubtitle)
        .foregroundColor(.SDKTextSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AppTheme.Spacing.md)
    .padding(.horizontal, AppTheme.Spacing.lg)
    .background(
      RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
        .fill(color.opacity(0.15))
        .overlay(
          RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
            .stroke(color.opacity(0.3), lineWidth: 1)
        )
    )
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }
}
