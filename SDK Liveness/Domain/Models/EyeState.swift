//
//  EyeState.swift
//  SDK Liveness
//

import Foundation

/// Represents the state of eyes based on Eye Aspect Ratio
struct EyeState: Equatable {
    /// Eye Aspect Ratio for left eye
    let leftEAR: Double
    /// Eye Aspect Ratio for right eye
    let rightEAR: Double

    /// Average EAR of both eyes
    var averageEAR: Double {
        (leftEAR + rightEAR) / 2.0
    }

    /// Whether eyes are considered closed (blinking)
    var isClosed: Bool {
        averageEAR < LivenessThresholds.eyeClosedEARThreshold
    }

    /// Whether eyes are considered open
    var isOpen: Bool {
        averageEAR > LivenessThresholds.eyeOpenEARThreshold
    }

    static let defaultOpen = EyeState(leftEAR: 0.3, rightEAR: 0.3)
}
