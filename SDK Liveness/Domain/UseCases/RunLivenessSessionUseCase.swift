//
//  RunLivenessSessionUseCase.swift
//  SDK Liveness
//

import Foundation

/// Orchestrates the full liveness session — manages action sequence and validates each action
final class RunLivenessSessionUseCase {

    // MARK: - Dependencies
    private let detectFaceUseCase: DetectFaceUseCase
    private let validateHeadTurnUseCase: ValidateHeadTurnUseCase
    private let validateBlinkUseCase: ValidateBlinkUseCase
    private let validateSmileUseCase: ValidateSmileUseCase
    private let validateNodUseCase: ValidateNodUseCase
    private let validateAntiSpoofUseCase: ValidateAntiSpoofUseCase

    // MARK: - Init
    init(
        detectFaceUseCase: DetectFaceUseCase,
        validateHeadTurnUseCase: ValidateHeadTurnUseCase,
        validateBlinkUseCase: ValidateBlinkUseCase,
        validateSmileUseCase: ValidateSmileUseCase,
        validateNodUseCase: ValidateNodUseCase,
        validateAntiSpoofUseCase: ValidateAntiSpoofUseCase = ValidateAntiSpoofUseCase()
    ) {
        self.detectFaceUseCase = detectFaceUseCase
        self.validateHeadTurnUseCase = validateHeadTurnUseCase
        self.validateBlinkUseCase = validateBlinkUseCase
        self.validateSmileUseCase = validateSmileUseCase
        self.validateNodUseCase = validateNodUseCase
        self.validateAntiSpoofUseCase = validateAntiSpoofUseCase
    }

    // MARK: - Face Detection
    func checkFace(data: FaceAnalysisData) -> LivenessError? {
        // Check anti-spoof first
        if let spoofError = validateAntiSpoofUseCase.validate(data: data) {
            return spoofError
        }
        return detectFaceUseCase.execute(data: data)
    }

    func isFaceReady(data: FaceAnalysisData) -> Bool {
        detectFaceUseCase.isFaceReady(data: data)
    }

    // MARK: - Action Validation

    /// Process a frame for the given action
    /// - Parameters:
    ///   - action: Current liveness action to validate
    ///   - data: Face analysis data for this frame
    /// - Returns: ActionResult if action is complete, nil if still in progress
    func validateAction(_ action: LivenessAction, data: FaceAnalysisData) -> ActionResult? {
        switch action {
        case .turnLeft, .turnRight:
            return validateHeadTurnUseCase.execute(data: data, direction: action)
        case .blink:
            return validateBlinkUseCase.execute(data: data)
        case .smile:
            return validateSmileUseCase.execute(data: data)
        case .nod:
            return validateNodUseCase.execute(data: data)
        }
    }

    /// Reset the validator for a specific action (call when moving to next action)
    func resetAction(_ action: LivenessAction) {
        switch action {
        case .turnLeft, .turnRight:
            validateHeadTurnUseCase.reset()
        case .blink:
            validateBlinkUseCase.reset()
        case .smile:
            validateSmileUseCase.reset()
        case .nod:
            validateNodUseCase.reset()
        }
    }

    /// Reset all validators
    func resetAll() {
        validateHeadTurnUseCase.reset()
        validateBlinkUseCase.reset()
        validateSmileUseCase.reset()
        validateNodUseCase.reset()
    }

    /// Generate a unique session ID
    func generateSessionId() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: Date())
        let random = String(format: "%06d", Int.random(in: 0...999999))
        return "AIN-\(year)-\(random)"
    }
}
