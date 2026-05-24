//
//  HeadPose.swift
//  SDK Liveness
//

import Foundation

/// Represents head orientation in 3D space (all values in degrees)
struct HeadPose: Equatable {
  /// Yaw: rotation around Y axis. Positive = looking left, Negative = looking right
  let yaw: Double
  /// Pitch: rotation around X axis. Positive = looking up, Negative = looking down
  let pitch: Double
  /// Roll: rotation around Z axis. Positive = tilting right, Negative = tilting left
  let roll: Double

  var isNeutral: Bool {
    abs(yaw) < LivenessThresholds.headTurnNeutralThreshold
      && abs(pitch) < LivenessThresholds.nodNeutralThreshold
  }

  var isTurnedLeft: Bool {
    yaw > LivenessThresholds.headTurnYawThreshold && abs(pitch) < 35.0
  }

  var isTurnedRight: Bool {
    yaw < -LivenessThresholds.headTurnYawThreshold && abs(pitch) < 35.0
  }

  var isNodding: Bool {
    pitch > abs(LivenessThresholds.nodPitchThreshold) && abs(yaw) < 25.0
  }

  static let zero = HeadPose(yaw: 0, pitch: 0, roll: 0)
}
