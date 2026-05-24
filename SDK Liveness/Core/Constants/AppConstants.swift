//
//  AppConstants.swift
//  SDK Liveness
//

import Foundation

enum AppConstants {
  // MARK: - App Info
  static let appName = "SDKLiveness"
  static let appVersion = "0.0.1"
  static let poweredBy = "Powered by Switt"

  // MARK: - Session
  static let sessionTimeoutSeconds: TimeInterval = 60
  static let faceDetectionDelaySeconds: TimeInterval = 1.5
  static let actionCompleteDisplaySeconds: TimeInterval = 2.0
  static let maxRetryAttempts = 3

  // MARK: - Camera
  static let cameraFrameRate: Int32 = 30
  static let cameraPosition: CameraPosition = .front

  // MARK: - Face Detection
  static let faceDetectionConfidence: Float = 0.5
  static let faceInOvalThreshold: CGFloat = 0.15  // tolerance for face centering

  enum CameraPosition {
    case front
    case back
  }
}
