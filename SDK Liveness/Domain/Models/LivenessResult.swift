//
//  LivenessResult.swift
//  SDK Liveness
//

import Foundation

/// Final result of the complete liveness verification session
struct LivenessResult: Equatable {
    let sessionId: String
    let passed: Bool
    let actionResults: [ActionResult]
    let startTime: Date
    let endTime: Date
    let errorMessage: String?

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var overallConfidence: Double {
        guard !actionResults.isEmpty else { return 0 }
        return actionResults.map(\.confidence).reduce(0, +) / Double(actionResults.count)
    }

    static func success(sessionId: String, actionResults: [ActionResult], startTime: Date) -> LivenessResult {
        LivenessResult(
            sessionId: sessionId,
            passed: true,
            actionResults: actionResults,
            startTime: startTime,
            endTime: Date(),
            errorMessage: nil
        )
    }

    static func failure(sessionId: String, actionResults: [ActionResult], startTime: Date, error: String) -> LivenessResult {
        LivenessResult(
            sessionId: sessionId,
            passed: false,
            actionResults: actionResults,
            startTime: startTime,
            endTime: Date(),
            errorMessage: error
        )
    }
}
