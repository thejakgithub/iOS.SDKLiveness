//
//  AntiSpoofThresholds.swift
//  SDK Liveness
//

import Foundation

/// Threshold values for anti-spoof depth analysis.
/// These are based on typical TrueDepth disparity observations.
enum AntiSpoofThresholds {
    /// Minimum depth curvature to classify a face as real (3D).
    /// - Real face: positive curvature (nose is closer than cheeks) -> ~0.05 to 0.3
    /// - Photo/screen: ~0.0 (flat plane), even if tilted.
    static let minDepthCurvature: Float = 0.05
}
