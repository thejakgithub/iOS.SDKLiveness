//
//  ValidateSmileUseCase.swift
//  SDK Liveness
//

import Foundation
import os

/// Validates smile action using lip width ratio
final class ValidateSmileUseCase {

    /// Reset state for a new action attempt
    func reset() {
        // No state needed since we pass immediately
    }

    /// Process a single frame of face data
    /// - Parameter data: Current face analysis data
    /// - Returns: ActionResult if smile is validated, nil if still in progress
    func execute(data: FaceAnalysisData) -> ActionResult? {
        guard data.isFaceDetected else {
            return nil
        }

        let smileState = data.smileState

        if smileState.isSmiling {
            LivenessLogger.liveness.info("Smile validated (ratio: \(smileState.smileRatio), confidence: \(smileState.confidence))")
            return .success(.smile, confidence: smileState.confidence)
        }

        return nil
    }
}
