//
//  SmileDetectorCalculator.swift
//  SDK Liveness
//

import CoreGraphics
import Vision
import os

/// Calculates smile metrics from lip landmarks using Mouth Aspect Ratio (MAR).
///
/// MAR = mouth width / mouth height.
/// When smiling, the mouth stretches wider and gets thinner, so MAR increases.
/// This metric is person-independent when used with adaptive baseline comparison.
struct SmileDetectorCalculator {

  /// Calculate smile ratio from outer lip landmarks and face bounding box
  /// Uses dual-signal detection: mouth width AND corner uplift (more accurate)
  func analyzeSmile(from landmarks: VNFaceLandmarks2D, faceBoundingBox: CGRect) -> SmileState {
    guard let outerLips = landmarks.outerLips else {
      return .neutral
    }

    let points = outerLips.normalizedPoints

    // Need at least 12 points to detect corners reliably
    guard points.count >= 6 else {
      LivenessLogger.vision.warning("Outer lips has insufficient points: \(points.count)")
      return .neutral
    }

    // --- Signal 1: Mouth width ratio ---
    let xs = points.map { $0.x }
    let ys = points.map { $0.y }
    let minX = xs.min() ?? 0
    let maxX = xs.max() ?? 0
    let mouthWidth = maxX - minX

    // --- Signal 2: Corner uplift ---
    // In Vision coords (Y flipped), smile means corners Y is LOWER than lip top
    // outerLips points: index 0 = right corner, ~6 = left corner, middle points = top/bottom lip
    // We compare corner Y vs the average Y of the center top lip points
    let cornerY = (points[0].y + points[points.count / 2].y) / 2.0
    let minY = ys.min() ?? 0
    let maxY = ys.max() ?? 0
    let lipHeight = maxY - minY

    // Normalized uplift: how far corners are from the top of the lip
    // Positive value = corners are above center of lip = smile shape
    let centerY = (minY + maxY) / 2.0
    let cornerUplift = cornerY - centerY  // positive means corners are above center

    // Combine both signals into a single composite smile score
    // Width contributes 50%, uplift contributes 50%
    let widthScore = mouthWidth
    let upliftScore = max(0, cornerUplift / max(lipHeight, 0.001))
    let smileScore = (widthScore * 0.6) + (upliftScore * 0.4)

    LivenessLogger.vision.debug(
      "Smile: width=\(mouthWidth, format: .fixed(precision: 3)) uplift=\(cornerUplift, format: .fixed(precision: 3)) score=\(smileScore, format: .fixed(precision: 3))"
    )

    return SmileState(smileRatio: smileScore)
  }
}
