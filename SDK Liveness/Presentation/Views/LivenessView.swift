//
//  LivenessView.swift
//  SDK Liveness
//

import SwiftUI

/// Screens 03-06: Main liveness camera view with face detection, actions, and progress
struct LivenessView: View {
  @ObservedObject var viewModel: LivenessViewModel

  var body: some View {
    ZStack {
      Color.SDKBackground
        .ignoresSafeArea()

      VStack(spacing: AppTheme.Spacing.md) {
        Spacer()
          .frame(height: AppTheme.Spacing.xl)

        // Camera container
        cameraContainer

        // Status banner
        statusBanner

        // Guidance message
        if !isShowingBanner {
          Text(viewModel.guidanceMessage)
            .font(AppTheme.Font.subheadline)
            .foregroundColor(.SDKTextSecondary)
            .multilineTextAlignment(.center)
            .transition(.opacity)
            .animation(.easeInOut, value: viewModel.guidanceMessage)
        }

        // Progress bar
        ProgressBarView(
          totalSteps: viewModel.totalActions + 1,  // +1 for face detection step
          currentStep: viewModel.progressStep + 1,
          activeColor: viewModel.activeColor
        )
        .padding(.horizontal, AppTheme.Spacing.xl)
        .padding(.top, AppTheme.Spacing.md)

        Spacer()
      }
      .padding(.horizontal, AppTheme.Spacing.md)
    }
    .task {
      await viewModel.startSession()
    }
    .onDisappear {
      viewModel.stopSession()
    }
  }

  // MARK: - Camera Container
  private var cameraContainer: some View {
    ZStack {
      // Camera container background
      RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
        .fill(Color.SDKCardBackground)

      // Camera preview
      if let previewLayer = viewModel.previewLayer {
        CameraPreviewView(previewLayer: previewLayer)
          .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
      }

      // Face oval overlay
      FaceOvalOverlay(state: viewModel.ovalState)

      // Action arrow indicator (for turn left/right/nod)
      if case .performingAction(let action) = viewModel.sessionState,
        [.turnLeft, .turnRight, .nod].contains(action)
      {
        actionArrowOverlay(action: action)
      }

      // Action complete checkmark
      if case .actionComplete = viewModel.sessionState {
        ZStack {
          Circle()
            .fill(Color.SDKSuccess.opacity(0.2))
            .frame(width: 60, height: 60)

          Image(systemName: "checkmark")
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(.SDKSuccess)
        }
        .transition(.scale.combined(with: .opacity))
      }
    }
    .frame(height: 420)
    .padding(.horizontal, AppTheme.Spacing.sm)
  }

  // MARK: - Action Arrow
  private func actionArrowOverlay(action: LivenessAction) -> some View {
    HStack {
      if action == .turnLeft {
        ActionArrowIndicator(direction: action)
        Spacer()
      } else if action == .turnRight {
        Spacer()
        ActionArrowIndicator(direction: action)
      }
    }
    .padding(.horizontal, AppTheme.Spacing.sm)
  }

  // MARK: - Status Banner
  @ViewBuilder
  private var statusBanner: some View {
    switch viewModel.sessionState {
    case .faceDetected:
      StatusBannerView(
        title: "พบใบหน้าแล้ว ✓",
        subtitle: "กรุณาทำตามคำแนะนำต่อไปนี้",
        color: .SDKSuccess
      )
      .padding(.horizontal, AppTheme.Spacing.sm)

    case .performingAction(let action):
      StatusBannerView(
        title: "\(action.iconSymbol) \(action.displayName)",
        subtitle: viewModel.guidanceMessage,
        color: viewModel.guidanceMessage == action.instruction ? .SDKWarning : .SDKError,
        icon: nil
      )
      .padding(.horizontal, AppTheme.Spacing.sm)

    case .actionComplete:
      StatusBannerView(
        title: "✓ สำเร็จ!",
        subtitle: "เยี่ยมมาก! กำลังประมวลผลข้อมูล...",
        color: .SDKSuccess
      )
      .padding(.horizontal, AppTheme.Spacing.sm)

    default:
      EmptyView()
    }
  }

  private var isShowingBanner: Bool {
    switch viewModel.sessionState {
    case .faceDetected, .performingAction, .actionComplete:
      return true
    default:
      return false
    }
  }
}
