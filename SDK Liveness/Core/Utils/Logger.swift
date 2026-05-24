//
//  Logger.swift
//  SDK Liveness
//

import Foundation
import os.log

enum LivenessLogger {
  private static let subsystem = Bundle.main.bundleIdentifier ?? "com.SDK.liveness"

  static let camera = Logger(subsystem: subsystem, category: "Camera")
  static let vision = Logger(subsystem: subsystem, category: "Vision")
  static let liveness = Logger(subsystem: subsystem, category: "Liveness")
  static let session = Logger(subsystem: subsystem, category: "Session")
  static let ui = Logger(subsystem: subsystem, category: "UI")
}
