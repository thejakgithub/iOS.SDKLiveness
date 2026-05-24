//
//  SplashView.swift
//  SDK Liveness
//

import SwiftUI

/// Screen 01: Splash Screen with logo and license check
struct SplashView: View {
  @ObservedObject var viewModel: SplashViewModel

  @State private var logoScale: CGFloat = 0.8
  @State private var logoOpacity: Double = 0

  var body: some View {
    ZStack {
      Color.SDKBackground
        .ignoresSafeArea()

      VStack(spacing: AppTheme.Spacing.xl) {
        Spacer()

        // Logo
        ZStack {
          Circle()
            .stroke(Color.SDKPrimary, lineWidth: 3)
            .frame(width: AppTheme.Size.splashLogoSize, height: AppTheme.Size.splashLogoSize)

          Circle()
            .fill(Color.SDKPrimary.opacity(0.1))
            .frame(
              width: AppTheme.Size.splashLogoSize - 10, height: AppTheme.Size.splashLogoSize - 10)

          // Mountain / face icon
          Image(systemName: "face.smiling")
            .font(.system(size: 60))
            .foregroundColor(.SDKPrimary)
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)

        // Title
        VStack(spacing: AppTheme.Spacing.sm) {
          Text(AppConstants.appName)
            .font(AppTheme.Font.largeTitle)
            .foregroundColor(.white)

          Text("AI Identity Verification")
            .font(AppTheme.Font.subheadline)
            .foregroundColor(.SDKTextSecondary)
        }
        .opacity(logoOpacity)

        Spacer()

        // Get Started (visible after license check)
        if case .licenseValid = viewModel.state {
          Text("Get Started")
            .font(AppTheme.Font.buttonTitle)
            .foregroundColor(.white)
            .transition(.opacity)
        }

        Spacer()
          .frame(height: AppTheme.Spacing.xxl)

        // Version info
        VStack(spacing: AppTheme.Spacing.xs) {
          Text("Version \(AppConstants.appVersion)")
            .font(AppTheme.Font.versionText)
            .foregroundColor(.SDKTextSecondary)

          Text(AppConstants.poweredBy)
            .font(AppTheme.Font.versionText)
            .foregroundColor(.SDKTextSecondary)
        }
        .opacity(logoOpacity)
      }
      .padding(.horizontal, AppTheme.Spacing.lg)
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.8)) {
        logoScale = 1.0
        logoOpacity = 1.0
      }

      Task {
        await viewModel.checkLicense()
      }
    }
  }
}
