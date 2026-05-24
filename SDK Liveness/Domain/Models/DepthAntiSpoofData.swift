//
//  DepthAntiSpoofData.swift
//  SDK Liveness
//

import Foundation

/// Result of depth-based anti-spoof analysis
struct DepthAntiSpoofData: Equatable {

  /// Whether TrueDepth camera is available on this device
  let isDepthAvailable: Bool

  /// Curvature of depth values across the face region.
  /// A real face is 3D so depth curvature is POSITIVE (nose protrudes).
  /// A flat photo/screen is 2D so depth curvature is ~0.
  let depthCurvature: Float

  /// True if waiting for first depth frame, or depth data is currently invalid
  let isUnknown: Bool

  /// Whether the face appears to be real (3D) based on depth
  var isLive: Bool {
    if isUnknown { return true }
    guard isDepthAvailable else {
      // No TrueDepth — assume live (fallback gracefully)
      return true
    }
    return depthCurvature >= AntiSpoofThresholds.minDepthCurvature
  }

  /// Unavailable state (device doesn't have TrueDepth)
  static let unavailable = DepthAntiSpoofData(
    isDepthAvailable: false, depthCurvature: 0, isUnknown: false)

  /// Unknown state (waiting for first depth frame)
  static let unknown = DepthAntiSpoofData(
    isDepthAvailable: true, depthCurvature: 0, isUnknown: true)
}
