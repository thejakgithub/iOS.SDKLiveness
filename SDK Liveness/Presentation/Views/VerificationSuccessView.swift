//
//  VerificationSuccessView.swift
//  SDK Liveness
//

import SwiftUI

/// Screen 07: Verification Passed
struct VerificationSuccessView: View {
  let sessionId: String
  var onContinue: (() -> Void)?

  @State private var iconScale: CGFloat = 0.5
  @State private var iconOpacity: Double = 0

  var body: some View {
    ZStack {
      Color.SDKBackground
        .ignoresSafeArea()

      VStack(spacing: AppTheme.Spacing.xl) {
        Spacer()

        // Success icon
        CircleIconView(
          systemName: "checkmark",
          color: .SDKSuccess,
          backgroundColor: .SDKSuccessBackground
        )
        .scaleEffect(iconScale)
        .opacity(iconOpacity)

        // Title
        VStack(spacing: AppTheme.Spacing.sm) {
          Text("Verification")
            .font(AppTheme.Font.title)
            .foregroundColor(.white)

          Text("Successful!")
            .font(AppTheme.Font.title)
            .foregroundColor(.SDKSuccess)
            .italic()
        }

        Text("Your identity has been verified")
          .font(AppTheme.Font.body)
          .foregroundColor(.SDKTextSecondary)

        // Session ID
        VStack(spacing: AppTheme.Spacing.xs) {
          Text("Session ID: \(sessionId)")
            .font(AppTheme.Font.subheadline)
            .foregroundColor(.SDKTextSecondary)
        }
        .padding(.vertical, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .background(
          RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
            .fill(Color.SDKSuccess.opacity(0.1))
            .overlay(
              RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(Color.SDKSuccess.opacity(0.2), lineWidth: 1)
            )
        )

        Spacer()

        // Continue button
        Button {
          onContinue?()
        } label: {
          Text("Continue")
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
