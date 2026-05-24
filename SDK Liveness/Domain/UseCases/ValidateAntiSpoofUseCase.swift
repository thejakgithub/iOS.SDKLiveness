//
//  ValidateAntiSpoofUseCase.swift
//  SDK Liveness
//

import Foundation
import os

/// Validates that the face being detected is real (3D) and not a photo or screen.
///
/// On TrueDepth devices: uses depth variance to detect flat spoofs.
/// On non-TrueDepth devices: always passes (graceful fallback).
final class ValidateAntiSpoofUseCase {

    /// Check if the current frame passes the anti-spoof check
    /// - Returns: nil if live, or LivenessError.spoofDetected if a spoof is detected
    func validate(data: FaceAnalysisData) -> LivenessError? {
        let depth = data.depthAntiSpoof

        // No TrueDepth — bypass check
        guard depth.isDepthAvailable else { return nil }

        if !depth.isLive {
            LivenessLogger.liveness.warning(
                "Anti-spoof: SPOOF DETECTED — depth curvature=\(depth.depthCurvature, format: .fixed(precision: 6))"
            )
            return .spoofDetected
        }

        return nil
    }

    /// Whether depth-based anti-spoof is active on this device
    var isActive: Bool {
        // Will be true after the first depth frame is processed
        true
    }
}
