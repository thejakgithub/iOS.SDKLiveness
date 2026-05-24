//
//  SmileState.swift
//  SDK Liveness
//

import Foundation

/// Represents smile detection state based on lip width ratio
struct SmileState: Equatable {
    /// Ratio of mouth width to face width
    let smileRatio: Double

    /// Whether the person is smiling above threshold
    var isSmiling: Bool {
        smileRatio > LivenessThresholds.smileRatioThreshold
    }

    /// Whether the mouth is in a neutral position
    var isNeutral: Bool {
        smileRatio < LivenessThresholds.smileNeutralThreshold
    }

    /// Normalized confidence score (0.0 - 1.0)
    var confidence: Double {
        let range = LivenessThresholds.smileRatioThreshold - LivenessThresholds.smileNeutralThreshold
        guard range > 0 else { return 0 }
        let normalized = (smileRatio - LivenessThresholds.smileNeutralThreshold) / range
        return min(max(normalized, 0), 1)
    }

    static let neutral = SmileState(smileRatio: 0.38)
}
