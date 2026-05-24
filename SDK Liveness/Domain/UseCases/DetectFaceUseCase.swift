//
//  DetectFaceUseCase.swift
//  SDK Liveness
//

import CoreGraphics

/// Detects whether a face is present and properly centered in the oval guide
final class DetectFaceUseCase {

  /// Check if face is detected and centered
  /// - Parameters:
  ///   - data: Face analysis data from Vision
  ///   - ovalRect: The oval guide rect in normalized coordinates (0-1)
  /// - Returns: nil if face is properly positioned, or an error describing the issue
  func execute(data: FaceAnalysisData, ovalRect: CGRect? = nil) -> LivenessError? {
    guard data.isFaceDetected else {
      return .noFaceDetected
    }

    guard data.faceConfidence >= AppConstants.faceDetectionConfidence else {
      return .noFaceDetected
    }

    // Check if face is completely inside the oval bounds
    let faceBounds = data.faceBoundingBox

    // Define oval bounds in normalized coordinates (approximate based on UI design)
    // Oval is roughly 55% of width and 70% of height, centered.
    // Tighter bounds so the user must position their face closer to the oval.
    let minX: CGFloat = 0.15
    let maxX: CGFloat = 0.85
    let minY: CGFloat = 0.10
    let maxY: CGFloat = 0.90

    if faceBounds.minX < minX || faceBounds.maxX > maxX || faceBounds.minY < minY
      || faceBounds.maxY > maxY
    {
      return .faceNotCentered
    }

    // Check face size (not too far, not too close)
    let faceArea = faceBounds.width * faceBounds.height
    if faceArea < 0.12 {
      return .faceTooFar
    }
    if faceArea > 0.45 {
      return .faceTooClose
    }

    return nil  // Face is properly positioned
  }

  /// Convenience: returns true if face is properly detected and centered
  func isFaceReady(data: FaceAnalysisData) -> Bool {
    execute(data: data) == nil
  }
}
