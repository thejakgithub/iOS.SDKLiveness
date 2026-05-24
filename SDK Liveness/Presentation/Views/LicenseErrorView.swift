//
//  LicenseErrorView.swift
//  SDK Liveness
//

import SwiftUI

/// Screen 10: License Error
struct LicenseErrorView: View {
  let errorCode: String
  var onContactSupport: (() -> Void)?

  @State private var iconScale: CGFloat = 0.5
  @State private var iconOpacity: Double = 0

  var body: some View {
    ZStack {
      Color.SDKBackground
        .ignoresSafeArea()

      VStack(spacing: AppTheme.Spacing.xl) {
        Spacer()

        // Warning icon
        CircleIconView(
          systemName: "exclamationmark.triangle.fill",
          color: .SDKError,
          backgroundColor: .SDKErrorBackground
        )
        .scaleEffect(iconScale)
        .opacity(iconOpacity)

        // Title
        Text("License Error")
          .font(AppTheme.Font.title)
          .foregroundColor(.white)

        Text("SDK license is invalid or expired.")
          .font(AppTheme.Font.body)
          .foregroundColor(.SDKTextSecondary)

        // Error code
        VStack(spacing: AppTheme.Spacing.xs) {
          Text("Error Code")
            .font(AppTheme.Font.caption)
            .foregroundColor(.SDKTextSecondary)

          Text(errorCode)
            .font(AppTheme.Font.headline)
            .foregroundColor(.SDKError)
        }
        .padding(.vertical, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
          RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
            .fill(Color.SDKError.opacity(0.1))
            .overlay(
              RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(Color.SDKError.opacity(0.2), lineWidth: 1)
            )
        )
        .padding(.horizontal, AppTheme.Spacing.xl)

        Spacer()

        // Contact Support button
        Button {
          onContactSupport?()
        } label: {
          Text("Contact Support")
            .font(AppTheme.Font.buttonTitle)
            .foregroundColor(.white)
        }
        .padding(.bottom, AppTheme.Spacing.xxl)
      }
      .padding(.horizontal, AppTheme.Spacing.lg)
    }
    .onAppear {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
        iconScale = 1.0
        iconOpacity = 1.0
      }
    }
  }
}
