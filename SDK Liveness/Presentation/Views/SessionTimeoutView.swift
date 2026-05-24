//
//  SessionTimeoutView.swift
//  SDK Liveness
//

import SwiftUI

/// Screen 09: Session Timed Out
struct SessionTimeoutView: View {
  var onStartOver: (() -> Void)?

  @State private var iconScale: CGFloat = 0.5
  @State private var iconOpacity: Double = 0

  var body: some View {
    ZStack {
      Color.SDKBackground
        .ignoresSafeArea()

      VStack(spacing: AppTheme.Spacing.xl) {
        Spacer()

        // Clock icon
        CircleIconView(
          systemName: "clock.fill",
          color: .SDKWarning,
          backgroundColor: .SDKWarningBackground
        )
        .scaleEffect(iconScale)
        .opacity(iconOpacity)

        // Title
        Text("Session Timed Out")
          .font(AppTheme.Font.title)
          .foregroundColor(.white)

        Text("Your session has expired due to\ninactivity. Please start over.")
          .font(AppTheme.Font.body)
          .foregroundColor(.SDKTextSecondary)
          .multilineTextAlignment(.center)

        Spacer()

        // Start Over button
        Button {
          onStartOver?()
        } label: {
          Text("Start Over")
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
