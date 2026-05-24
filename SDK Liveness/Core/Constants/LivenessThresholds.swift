//
//  LivenessThresholds.swift
//  SDK Liveness
//

import Foundation

/// Threshold values for liveness action detection.
/// These values should be tuned based on real-device testing.
enum LivenessThresholds {

  // MARK: - Head Turn (Yaw)
  /// Minimum yaw angle (degrees) to consider a head turn detected
  // TODO: - Need to tune this value
  static let headTurnYawThreshold: Double = 7.0
  /// Yaw angle (degrees) considered as neutral / facing forward
  static let headTurnNeutralThreshold: Double = 7.0
  /// Minimum frames the turn must be held
  static let headTurnHoldFrames: Int = 1

  // MARK: - Blink (Eye Aspect Ratio)
  /// EAR below this value = eye is closed
  static let eyeClosedEARThreshold: Double = 0.22
  /// EAR above this value = eye is open
  static let eyeOpenEARThreshold: Double = 0.24
  /// Minimum consecutive frames eye must be closed to count as blink
  static let blinkClosedMinFrames: Int = 1
  /// Minimum consecutive frames eye must reopen after close
  static let blinkOpenMinFrames: Int = 1

  // MARK: - Smile (Lip Width Ratio)
  /// Composite smile score above this = smiling (width 50% + uplift 50%)
  static let smileRatioThreshold: Double = 0.25
  /// Composite score below this = neutral mouth
  static let smileNeutralThreshold: Double = 0.15

  // MARK: - Nod (Pitch)
  /// Minimum pitch angle (degrees, positive = looking down) for nod detection
  // TODO: - Need to tune this value
  static let nodPitchThreshold: Double = -8.0
  /// Pitch angle (degrees) considered neutral
  static let nodNeutralThreshold: Double = 4.0
  /// Minimum frames the nod must be held
  static let nodHoldFrames: Int = 1
}
