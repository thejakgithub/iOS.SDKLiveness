//
//  ValidateHeadTurnUseCase.swift
//  SDK Liveness
//

import Foundation
import os

/// Validates head turn left/right action using VNFaceObservation yaw angle
final class ValidateHeadTurnUseCase {

    enum TurnPhase {
        case waitingForTurn    // Waiting for user to turn head
        case turnDetected      // Head is turned past threshold
        case returningNeutral  // Waiting to return to neutral
        case completed         // Full cycle complete
    }

    private var phase: TurnPhase = .waitingForTurn
    private var holdFrameCount: Int = 0

    /// Reset state for a new action attempt
    func reset() {
        phase = .waitingForTurn
        holdFrameCount = 0
    }

    /// Process a single frame of face data
    /// - Parameters:
    ///   - data: Current face analysis data
    ///   - direction: Which direction to validate (.turnLeft or .turnRight)
    /// - Returns: ActionResult if the action is complete, nil if still in progress
    func execute(data: FaceAnalysisData, direction: LivenessAction) -> ActionResult? {
        guard data.isFaceDetected else {
            // Lost face tracking — don't reset, just skip
            return nil
        }

        let headPose = data.headPose

        switch phase {
        case .waitingForTurn:
            let isTurned = (direction == .turnLeft) ? headPose.isTurnedLeft : headPose.isTurnedRight
            if isTurned {
                holdFrameCount += 1
                if holdFrameCount >= LivenessThresholds.headTurnHoldFrames {
                    phase = .completed
                    LivenessLogger.liveness.info("Head turn completed: \(direction.displayName)")
                    let confidence = min(abs(headPose.yaw) / LivenessThresholds.headTurnYawThreshold, 1.0)
                    return .success(direction, confidence: confidence)
                }
            } else {
                holdFrameCount = 0
            }

        case .turnDetected, .returningNeutral, .completed:
            break
        }

        return nil
    }
}
