//
//  VerificationFailedView.swift
//  SDK Liveness
//

import SwiftUI

/// Screen 08: Verification Failed
struct VerificationFailedView: View {
  var onTryAgain: (() -> Void)?
  var onGetHelp: (() -> Void)?

  @State private var iconScale: CGFloat = 0.5
  @State private var iconOpacity: Double = 0

  var body: some View {
    ZStack {
      Color.SDKBackground
        .ignoresSafeArea()

      VStack(spacing: AppTheme.Spacing.xl) {
        Spacer()

        // Failed icon
        CircleIconView(
          systemName: "xmark",
          color: .SDKError,
          backgroundColor: .SDKErrorBackground
        )
        .scaleEffect(iconScale)
        .opacity(iconOpacity)

        // Title
        VStack(spacing: AppTheme.Spacing.sm) {
          Text("Verification")
            .font(AppTheme.Font.title)
            .foregroundColor(.white)

          Text("Failed")
            .font(AppTheme.Font.title)
            .foregroundColor(.SDKError)
            .italic()
        }

        Text("Could not verify your identity.\nPlease try again.")
          .font(AppTheme.Font.body)
          .foregroundColor(.SDKTextSecondary)
          .multilineTextAlignment(.center)

        Spacer()

        // Buttons
        VStack(spacing: AppTheme.Spacing.md) {
          Button {
            onTryAgain?()
          } label: {
            Text("Try Again")
              .font(AppTheme.Font.buttonTitle)
              .foregroundColor(.white)
          }

          Button {
            onGetHelp?()
          } label: {
            Text("Get Help")
              .font(AppTheme.Font.buttonTitle)
              .foregroundColor(.SDKTextSecondary)
              .frame(maxWidth: .infinity)
              .padding(.vertical, AppTheme.Spacing.md)
              .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                  .fill(Color.white.opacity(0.1))
              )
          }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
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
