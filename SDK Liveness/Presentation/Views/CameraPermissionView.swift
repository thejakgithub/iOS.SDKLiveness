//
//  CameraPermissionView.swift
//  SDK Liveness
//

import SwiftUI

/// Screen 02: Camera Permission Request
struct CameraPermissionView: View {
    @ObservedObject var viewModel: CameraPermissionViewModel

    var body: some View {
        ZStack {
            Color.SDKBackground
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                // Camera icon
                ZStack {
                    Circle()
                        .stroke(Color.SDKPrimary.opacity(0.5), lineWidth: 2)
                        .frame(width: AppTheme.Size.permissionIconSize, height: AppTheme.Size.permissionIconSize)

                    Circle()
                        .fill(Color.SDKPrimary.opacity(0.1))
                        .frame(width: AppTheme.Size.permissionIconSize - 10, height: AppTheme.Size.permissionIconSize - 10)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.SDKPrimary.opacity(0.7))
                }

                // Title & description
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("Camera Access")
                        .font(AppTheme.Font.title)
                        .foregroundColor(.white)

                    Text("\(AppConstants.appName) needs camera access\nto verify your identity.")
                        .font(AppTheme.Font.body)
                        .foregroundColor(.SDKTextSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Buttons
                VStack(spacing: AppTheme.Spacing.md) {
                    Button {
                        Task {
                            await viewModel.requestPermission()
                        }
                    } label: {
                        Text("Allow Camera")
                            .font(AppTheme.Font.buttonTitle)
                            .foregroundColor(.white)
                    }

                    Button {
                        // Not Now — could dismiss or show alternative
                    } label: {
                        Text("Not Now")
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
        }
    }
}
