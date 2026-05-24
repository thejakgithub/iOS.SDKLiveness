//
//  VisionFaceAnalyzer.swift
//  SDK Liveness
//

import AVFoundation
import Combine
import Vision
import os

/// Apple Vision framework wrapper for face detection, landmarks, and pose analysis
final class VisionFaceAnalyzer: VisionFaceAnalyzerProtocol {

  // MARK: - Published
  private let analysisSubject = PassthroughSubject<FaceAnalysisData, Never>()
  var analysisPublisher: AnyPublisher<FaceAnalysisData, Never> {
    analysisSubject.eraseToAnyPublisher()
  }

  // MARK: - Dependencies
  private let earCalculator = EyeAspectRatioCalculator()
  private let smileCalculator = SmileDetectorCalculator()
  private let depthAnalyzer = DepthAntiSpoofAnalyzer()

  // MARK: - Vision Requests
  private lazy var faceDetectionRequest: VNDetectFaceRectanglesRequest = {
    let request = VNDetectFaceRectanglesRequest()
    return request
  }()

  private lazy var faceLandmarksRequest: VNDetectFaceLandmarksRequest = {
    let request = VNDetectFaceLandmarksRequest()
    return request
  }()

  // MARK: - State
  private let analysisQueue = DispatchQueue(label: "com.SDK.liveness.vision", qos: .userInteractive)
  private var isProcessing = false

  // MARK: - Analysis
  func analyze(sampleBuffer: CMSampleBuffer) {
    // Skip if already processing a frame
    guard !isProcessing else { return }
    isProcessing = true

    analysisQueue.async { [weak self] in
      defer { self?.isProcessing = false }
      self?.performAnalysis(sampleBuffer: sampleBuffer)
    }
  }

  private func performAnalysis(sampleBuffer: CMSampleBuffer) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      LivenessLogger.vision.warning("Failed to get pixel buffer from sample buffer")
      analysisSubject.send(.empty)
      return
    }

    let handler = VNImageRequestHandler(
      cvPixelBuffer: pixelBuffer,
      orientation: .leftMirrored,
      options: [:]
    )

    do {
      try handler.perform([faceDetectionRequest, faceLandmarksRequest])
      let result = processResults()
      analysisSubject.send(result)
    } catch {
      LivenessLogger.vision.error("Vision analysis failed: \(error.localizedDescription)")
      analysisSubject.send(.empty)
    }
  }

  private func processResults() -> FaceAnalysisData {
    let timestamp = ProcessInfo.processInfo.systemUptime

    // Get face detection results (for head pose)
    guard let faceObservation = faceDetectionRequest.results?.first else {
      return FaceAnalysisData(
        headPose: .zero,
        eyeState: .defaultOpen,
        smileState: .neutral,
        faceBoundingBox: .zero,
        faceConfidence: 0,
        isFaceDetected: false,
        timestamp: timestamp,
        depthAntiSpoof: depthAnalyzer.latestResult
      )
    }

    // Extract head pose
    let headPose = faceObservation.headPose

    // Get face landmarks results (for eyes & mouth)
    let landmarkObservation = faceLandmarksRequest.results?.first
    let landmarks = landmarkObservation?.landmarks

    // Calculate eye state (EAR)
    let eyeState: EyeState
    if let landmarks = landmarks {
      eyeState = earCalculator.analyzeEyes(from: landmarks)
    } else {
      eyeState = .defaultOpen
    }

    // Calculate smile state
    let smileState: SmileState
    if let landmarks = landmarks {
      smileState = smileCalculator.analyzeSmile(
        from: landmarks,
        faceBoundingBox: faceObservation.boundingBox
      )
    } else {
      smileState = .neutral
    }

    return FaceAnalysisData(
      headPose: headPose,
      eyeState: eyeState,
      smileState: smileState,
      faceBoundingBox: faceObservation.boundingBox,
      faceConfidence: faceObservation.confidence,
      isFaceDetected: true,
      timestamp: timestamp,
      depthAntiSpoof: depthAnalyzer.latestResult
    )
  }

  // MARK: - Depth (TrueDepth Anti-Spoof)
  func updateDepth(_ depthData: AVDepthData, faceBoundingBox: CGRect?) {
    depthAnalyzer.processDepthData(depthData, faceBoundingBox: faceBoundingBox)
  }
}
