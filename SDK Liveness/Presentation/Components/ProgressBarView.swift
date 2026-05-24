//
//  ProgressBarView.swift
//  SDK Liveness
//

import SwiftUI

/// Step progress bar showing liveness check progress
struct ProgressBarView: View {
    let totalSteps: Int
    let currentStep: Int
    let activeColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: AppTheme.Size.progressBarHeight / 2)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: AppTheme.Size.progressBarHeight)

                // Filled progress
                RoundedRectangle(cornerRadius: AppTheme.Size.progressBarHeight / 2)
                    .fill(activeColor)
                    .frame(
                        width: progressWidth(totalWidth: geometry.size.width),
                        height: AppTheme.Size.progressBarHeight
                    )
                    .animation(.easeInOut(duration: AnimationConstants.progressBarFill), value: currentStep)
            }
        }
        .frame(height: AppTheme.Size.progressBarHeight)
    }

    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        guard totalSteps > 0 else { return 0 }
        let progress = CGFloat(currentStep) / CGFloat(totalSteps)
        return totalWidth * min(progress, 1.0)
    }
}
