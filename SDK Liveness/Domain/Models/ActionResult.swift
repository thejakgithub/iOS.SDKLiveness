//
//  ActionResult.swift
//  SDK Liveness
//

import Foundation

/// Result of a single liveness action validation
struct ActionResult: Equatable {
    let action: LivenessAction
    let passed: Bool
    let confidence: Double
    let timestamp: Date

    static func success(_ action: LivenessAction, confidence: Double = 1.0) -> ActionResult {
        ActionResult(action: action, passed: true, confidence: confidence, timestamp: Date())
    }

    static func failure(_ action: LivenessAction, confidence: Double = 0.0) -> ActionResult {
        ActionResult(action: action, passed: false, confidence: confidence, timestamp: Date())
    }
}
