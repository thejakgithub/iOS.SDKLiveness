//
//  ResultViewModel.swift
//  SDK Liveness
//

import SwiftUI
import Combine

@MainActor
final class ResultViewModel: ObservableObject {
    @Published var result: LivenessResult

    init(result: LivenessResult) {
        self.result = result
    }

    var sessionId: String { result.sessionId }
    var isPassed: Bool { result.passed }
    var confidence: Double { result.overallConfidence }
    var duration: TimeInterval { result.duration }
    var errorMessage: String? { result.errorMessage }
}
