//
//  FaceOvalOverlay.swift
//  SDK Liveness
//

import SwiftUI

/// Animated face oval guide overlay — changes style based on state
struct FaceOvalOverlay: View {
  let state: OvalState

  enum OvalState {
    case positioning  // Dashed purple — waiting for face
    case detected  // Solid green — face found
    case action  // Solid orange — performing action
    case complete  // Solid green with checkmark — action done
    case error  // Solid red — face invalid or spoof detected
  }

  var body: some View {
    ZStack {
      // Oval shape
      Ellipse()
        .stroke(
          strokeColor,
          style: StrokeStyle(
            lineWidth: 3,
            dash: isDashed ? [10, 8] : []
          )
        )
        .frame(
          width: AppTheme.Size.faceOvalWidth,
          height: AppTheme.Size.faceOvalHeight
        )
        .animation(.easeInOut(duration: AnimationConstants.ovalColorTransition), value: state)

      // Checkmark overlay for complete state
      if state == .complete {
        Circle()
          .fill(Color.SDKSuccess.opacity(0.2))
          .frame(width: 50, height: 50)
          .overlay(
            Image(systemName: "checkmark")
              .font(.system(size: 24, weight: .bold))
              .foregroundColor(.SDKSuccess)
          )
          .transition(.scale.combined(with: .opacity))
      }
    }
  }

  private var strokeColor: Color {
    switch state {
    case .positioning: return .SDKPrimary
    case .detected: return .SDKSuccess
    case .action: return .SDKWarning
    case .complete: return .SDKSuccess
    case .error: return .SDKError
    }
  }

  private var isDashed: Bool {
    state == .positioning || state == .error
  }
}
