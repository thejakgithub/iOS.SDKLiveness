//
//  ValidateNodUseCase.swift
//  SDK Liveness
//

import Foundation
import os

/// Validates nod action using VNFaceObservation pitch angle
final class ValidateNodUseCase {

  enum NodPhase {
    case waitingForNeutral  // Head must be straight first to avoid instant trigger
    case waitingForNod      // Head is neutral, waiting for nod down
    case completed          // Full nod cycle complete
  }

  private var phase: NodPhase = .waitingForNeutral
  private var holdFrameCount: Int = 0

  /// Reset state for a new action attempt
  func reset() {
    phase = .waitingForNeutral
    holdFrameCount = 0
  }

  /// Process a single frame of face data
  /// - Parameter data: Current face analysis data
  /// - Returns: ActionResult if nod is complete, nil if still in progress
  func execute(data: FaceAnalysisData) -> ActionResult? {
    guard data.isFaceDetected else { return nil }

    let headPose = data.headPose

    switch phase {
    case .waitingForNeutral:
      if abs(headPose.pitch) < LivenessThresholds.nodNeutralThreshold {
        holdFrameCount += 1
        if holdFrameCount >= 1 { // Require looking straight for just 1 frame
          phase = .waitingForNod
          holdFrameCount = 0
        }
      } else {
        holdFrameCount = 0
      }

    case .waitingForNod:
      if headPose.isNodding {
        holdFrameCount += 1
        if holdFrameCount >= LivenessThresholds.nodHoldFrames {  // Configurable hold
          phase = .completed
          LivenessLogger.liveness.info("Nod completed successfully (pitch: \(headPose.pitch)°)")
          return .success(.nod, confidence: 1.0)
        }
      } else {
        holdFrameCount = 0
      }

    case .completed:
      break
    }

    return nil
  }
}
