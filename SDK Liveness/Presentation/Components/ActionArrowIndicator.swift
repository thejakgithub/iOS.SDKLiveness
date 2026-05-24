//
//  ActionArrowIndicator.swift
//  SDK Liveness
//

import SwiftUI

/// Animated arrow indicator shown during turn left/right actions
struct ActionArrowIndicator: View {
  let direction: LivenessAction

  @State private var isAnimating = false

  var body: some View {
    Image(systemName: arrowSystemName)
      .font(.system(size: AppTheme.Size.actionArrowSize, weight: .bold))
      .foregroundColor(.SDKWarning)
      .offset(x: isAnimating ? offsetAmount : 0)
      .animation(
        .easeInOut(duration: 0.8)
          .repeatForever(autoreverses: true),
        value: isAnimating
      )
      .onAppear {
        isAnimating = true
      }
  }

  private var arrowSystemName: String {
    switch direction {
    case .turnLeft: return "arrow.left"
    case .turnRight: return "arrow.right"
    case .nod: return "arrow.down"
    default: return ""
    }
  }

  private var offsetAmount: CGFloat {
    switch direction {
    case .turnLeft: return -15
    case .turnRight: return 15
    case .nod: return 0
    default: return 0
    }
  }
}
