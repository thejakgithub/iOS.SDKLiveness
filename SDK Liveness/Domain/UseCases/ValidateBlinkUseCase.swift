//
//  ValidateBlinkUseCase.swift
//  SDK Liveness
//

import Foundation
import os

/// Validates blink action using Eye Aspect Ratio (EAR)
final class ValidateBlinkUseCase {

    enum BlinkPhase {
        case waitingForNeutral // Eyes must be open first
        case waitingForClose   // Eyes are open, waiting for blink
        case eyesClosed        // Eyes closed, counting frames
        case waitingForReopen  // Eyes closed long enough, waiting for reopen
        case completed         // Full blink cycle complete
    }

    private var phase: BlinkPhase = .waitingForNeutral
    private var closedFrameCount: Int = 0
    private var openFrameCount: Int = 0

    /// Reset state for a new action attempt
    func reset() {
        phase = .waitingForNeutral
        closedFrameCount = 0
        openFrameCount = 0
    }

    /// Process a single frame of face data
    /// - Parameter data: Current face analysis data
    /// - Returns: ActionResult if blink is complete, nil if still in progress
    func execute(data: FaceAnalysisData) -> ActionResult? {
        guard data.isFaceDetected else { return nil }

        let eyeState = data.eyeState

        switch phase {
        case .waitingForNeutral:
            if eyeState.isOpen {
                openFrameCount += 1
                if openFrameCount >= 2 { // Require eyes open for 2 frames
                    phase = .waitingForClose
                    openFrameCount = 0
                }
            } else {
                openFrameCount = 0
            }

        case .waitingForClose:
            if eyeState.isClosed {
                closedFrameCount += 1
                if closedFrameCount >= LivenessThresholds.blinkClosedMinFrames {
                    phase = .waitingForReopen
                    LivenessLogger.liveness.info("Blink: eyes closed detected (EAR: \(eyeState.averageEAR))")
                }
            } else {
                closedFrameCount = 0
            }

        case .eyesClosed:
            // Transitional state, move to waiting for reopen
            phase = .waitingForReopen

        case .waitingForReopen:
            if eyeState.isOpen {
                openFrameCount += 1
                if openFrameCount >= LivenessThresholds.blinkOpenMinFrames {
                    phase = .completed
                    LivenessLogger.liveness.info("Blink completed successfully")
                    return .success(.blink, confidence: 1.0)
                }
            } else {
                openFrameCount = 0
            }

        case .completed:
            break
        }

        return nil
    }
}
