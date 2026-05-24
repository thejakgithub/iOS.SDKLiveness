//
//  EyeAspectRatioCalculator.swift
//  SDK Liveness
//

import Vision
import CoreGraphics
import os

/// Calculates Eye Aspect Ratio (EAR) from Vision framework eye landmarks
///
/// EAR formula: (|p2-p6| + |p3-p5|) / (2 * |p1-p4|)
/// where p1-p6 are the 6 key points around the eye
///
/// The Vision framework provides eye landmarks as normalized points.
/// - leftEye / rightEye have multiple points describing the eye contour
struct EyeAspectRatioCalculator {

    /// Calculate EAR from eye landmark region
    /// - Parameter eyeRegion: VNFaceLandmarkRegion2D for one eye (leftEye or rightEye)
    /// - Returns: EAR value. Lower = more closed. Typical open ≈ 0.25-0.30, closed < 0.15
    func calculateEAR(from eyeRegion: VNFaceLandmarkRegion2D) -> Double {
        let points = eyeRegion.normalizedPoints

        guard points.count >= 4 else {
            LivenessLogger.vision.warning("Eye region has insufficient points: \(points.count)")
            return 0.3 // Return default open value if insufficient points
        }

        let xs = points.map { $0.x }
        let ys = points.map { $0.y }

        let minX = xs.min() ?? 0
        let maxX = xs.max() ?? 0
        let minY = ys.min() ?? 0
        let maxY = ys.max() ?? 0

        let width = maxX - minX
        let height = maxY - minY

        guard width > 0 else { return 0.3 }

        // EAR approximation using bounding box
        return height / width
    }

    /// Calculate EAR for both eyes and return EyeState
    func analyzeEyes(from landmarks: VNFaceLandmarks2D) -> EyeState {
        guard let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else {
            return .defaultOpen
        }

        let leftEAR = calculateEAR(from: leftEye)
        let rightEAR = calculateEAR(from: rightEye)

        return EyeState(leftEAR: leftEAR, rightEAR: rightEAR)
    }
}
