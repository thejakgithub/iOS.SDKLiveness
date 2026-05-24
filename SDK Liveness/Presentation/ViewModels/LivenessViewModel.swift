//
//  LivenessViewModel.swift
//  SDK Liveness
//

import AVFoundation
import Combine
import SwiftUI
import os

@MainActor
final class LivenessViewModel: ObservableObject {

  // MARK: - Session State
  enum SessionState: Equatable {
    case initializing
    case detectingFace
    case faceDetected
    case performingAction(LivenessAction)
    case actionComplete(LivenessAction)
    case verificationPassed
    case verificationFailed
    case sessionTimeout
    case error(String)

    static func == (lhs: SessionState, rhs: SessionState) -> Bool {
      switch (lhs, rhs) {
      case (.initializing, .initializing),
        (.detectingFace, .detectingFace),
        (.faceDetected, .faceDetected),
        (.verificationPassed, .verificationPassed),
        (.verificationFailed, .verificationFailed),
        (.sessionTimeout, .sessionTimeout):
        return true
      case (.performingAction(let a), .performingAction(let b)):
        return a == b
      case (.actionComplete(let a), .actionComplete(let b)):
        return a == b
      case (.error(let a), .error(let b)):
        return a == b
      default:
        return false
      }
    }
  }

  // MARK: - Published Properties
  @Published var sessionState: SessionState = .initializing
  @Published var currentActionIndex: Int = 0
  @Published var faceAnalysis: FaceAnalysisData = .empty
  @Published var livenessResult: LivenessResult?
  @Published var guidanceMessage: String = "Position your face in the oval"
  @Published var remainingTime: TimeInterval = 0
  @Published var isSpoofDetected: Bool = false

  // MARK: - Config
  private var sessionConfig: LivenessSessionConfig = .default
  private var actionResults: [ActionResult] = []
  private var sessionStartTime: Date = Date()
  private var sessionId: String = ""

  // MARK: - Dependencies
  private let repository: LivenessRepositoryProtocol
  private let runSessionUseCase: RunLivenessSessionUseCase
  private let cameraManager: CameraManagerProtocol

  // MARK: - Timers & Subscriptions
  private var cancellables = Set<AnyCancellable>()
  private var timeoutTimer: Timer?
  private var faceDetectedDelayTask: Task<Void, Never>?

  // MARK: - Computed
  var currentAction: LivenessAction? {
    guard currentActionIndex < sessionConfig.actions.count else { return nil }
    return sessionConfig.actions[currentActionIndex]
  }

  var totalActions: Int { sessionConfig.actions.count }
  var progressStep: Int { currentActionIndex }

  var ovalState: FaceOvalOverlay.OvalState {
    if isSpoofDetected && sessionState != .initializing {
      return .positioning
    }
    switch sessionState {
    case .detectingFace: return .positioning
    case .faceDetected: return .detected
    case .performingAction: return .action
    case .actionComplete: return .complete
    default: return .positioning
    }
  }

  var activeColor: Color {
    if isSpoofDetected && sessionState != .initializing {
      return .SDKPrimary
    }
    switch sessionState {
    case .detectingFace: return .SDKPrimary
    case .faceDetected, .actionComplete: return .SDKSuccess
    case .performingAction: return .SDKWarning
    default: return .SDKPrimary
    }
  }

  var previewLayer: AVCaptureVideoPreviewLayer? {
    cameraManager.previewLayer
  }

  // MARK: - Init
  init(
    repository: LivenessRepositoryProtocol,
    runSessionUseCase: RunLivenessSessionUseCase,
    cameraManager: CameraManagerProtocol
  ) {
    self.repository = repository
    self.runSessionUseCase = runSessionUseCase
    self.cameraManager = cameraManager
  }

  // MARK: - Session Lifecycle

  func startSession(config: LivenessSessionConfig? = nil) async {
    let finalConfig = config ?? .default
    sessionConfig = finalConfig.randomizeOrder ? finalConfig.withRandomizedOrder() : finalConfig
    sessionId = runSessionUseCase.generateSessionId()
    sessionStartTime = Date()
    currentActionIndex = 0
    actionResults = []
    runSessionUseCase.resetAll()

    sessionState = .initializing

    do {
      try await repository.startLivenessCapture()

      // Subscribe to face analysis updates
      repository.faceAnalysisPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] data in
          self?.handleFaceAnalysis(data)
        }
        .store(in: &cancellables)

      sessionState = .detectingFace
      guidanceMessage = "Center your face in the oval"
      startTimeoutTimer()

      LivenessLogger.session.info("Liveness session started: \(self.sessionId)")
    } catch {
      sessionState = .error(error.localizedDescription)
      LivenessLogger.session.error("Failed to start session: \(error.localizedDescription)")
    }
  }

  func stopSession() {
    cancellables.removeAll()
    stopTimeoutTimer()
    faceDetectedDelayTask?.cancel()
    repository.stopLivenessCapture()
    LivenessLogger.session.info("Session stopped")
  }

  func restartSession() async {
    stopSession()
    await startSession(config: sessionConfig)
  }

  // MARK: - Frame Processing

  private func handleFaceAnalysis(_ data: FaceAnalysisData) {
    faceAnalysis = data
    isSpoofDetected = (runSessionUseCase.checkFace(data: data) == .spoofDetected)

    switch sessionState {
    case .detectingFace:
      handleDetectingFace(data)

    case .faceDetected:
      // Waiting for delay before starting actions
      if !runSessionUseCase.isFaceReady(data: data) {
        faceDetectedDelayTask?.cancel()
        sessionState = .detectingFace
        guidanceMessage = "กรุณาจัดใบหน้าให้อยู่ในกรอบวงรี"
      }

    case .performingAction(let action):
      handlePerformingAction(action, data: data)

    case .actionComplete:
      // Waiting for UI display, then auto-advance
      break

    default:
      break
    }
  }

  private func handleDetectingFace(_ data: FaceAnalysisData) {
    if runSessionUseCase.isFaceReady(data: data) {
      sessionState = .faceDetected
      guidanceMessage = "พบใบหน้าแล้ว ✓"
      HapticFeedback.faceDetected()

      // Delay before starting first action
      faceDetectedDelayTask = Task {
        try? await Task.sleep(
          nanoseconds: UInt64(AppConstants.faceDetectionDelaySeconds * 1_000_000_000))
        guard !Task.isCancelled else { return }
        advanceToNextAction()
      }
    } else {
      if let error = runSessionUseCase.checkFace(data: data) {
        guidanceMessage = error.localizedDescription
      }
    }
  }

  private func handlePerformingAction(_ action: LivenessAction, data: FaceAnalysisData) {
    // Check if face is still in the oval before validating the action
    if !runSessionUseCase.isFaceReady(data: data) {
      if let error = runSessionUseCase.checkFace(data: data) {
        guidanceMessage = error.localizedDescription
      }
      return
    } else {
      guidanceMessage = action.instruction
    }

    if let result = runSessionUseCase.validateAction(action, data: data) {
      // Action completed!
      actionResults.append(result)
      sessionState = .actionComplete(action)
      guidanceMessage = "เยี่ยมมาก! กำลังประมวลผลข้อมูล..."
      HapticFeedback.actionCompleted()

      // Delay then advance
      Task {
        try? await Task.sleep(
          nanoseconds: UInt64(AppConstants.actionCompleteDisplaySeconds * 1_000_000_000))
        currentActionIndex += 1

        if currentActionIndex >= sessionConfig.actions.count {
          completeVerification()
        } else {
          advanceToNextAction()
        }
      }
    }
  }

  private func advanceToNextAction() {
    guard let action = currentAction else {
      completeVerification()
      return
    }

    runSessionUseCase.resetAction(action)
    sessionState = .performingAction(action)
    guidanceMessage = action.instruction

    LivenessLogger.session.info(
      "Starting action: \(action.displayName) (\(self.currentActionIndex + 1)/\(self.totalActions))"
    )
  }

  // MARK: - Completion

  private func completeVerification() {
    stopTimeoutTimer()

    let allPassed = actionResults.allSatisfy { $0.passed }

    if allPassed {
      livenessResult = .success(
        sessionId: sessionId,
        actionResults: actionResults,
        startTime: sessionStartTime
      )
      sessionState = .verificationPassed
      HapticFeedback.verificationSuccess()
      LivenessLogger.session.info("Verification PASSED: \(self.sessionId)")
    } else {
      livenessResult = .failure(
        sessionId: sessionId,
        actionResults: actionResults,
        startTime: sessionStartTime,
        error: "One or more actions failed"
      )
      sessionState = .verificationFailed
      HapticFeedback.verificationFailed()
      LivenessLogger.session.info("Verification FAILED: \(self.sessionId)")
    }

    repository.stopLivenessCapture()
  }

  // MARK: - Timeout

  private func startTimeoutTimer() {
    remainingTime = sessionConfig.timeoutSeconds

    timeoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      Task { @MainActor in
        guard let self = self else { return }
        self.remainingTime -= 1

        if self.remainingTime <= 0 {
          self.handleTimeout()
        }
      }
    }
  }

  private func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  private func handleTimeout() {
    stopTimeoutTimer()
    repository.stopLivenessCapture()

    livenessResult = .failure(
      sessionId: sessionId,
      actionResults: actionResults,
      startTime: sessionStartTime,
      error: "Session timed out"
    )
    sessionState = .sessionTimeout
    HapticFeedback.sessionTimeout()
    LivenessLogger.session.info("Session TIMEOUT: \(self.sessionId)")
  }
}
