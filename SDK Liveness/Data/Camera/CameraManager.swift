//
//  CameraManager.swift
//  SDK Liveness
//

import AVFoundation
import Combine
import os

/// Manages AVCaptureSession for front camera video capture.
/// Supports TrueDepth camera (FaceID devices) for anti-spoof depth analysis.
/// Falls back gracefully to standard wide-angle camera on unsupported devices.
final class CameraManager: NSObject, CameraManagerProtocol {

  // MARK: - Published State
  private let frameSubject = PassthroughSubject<CMSampleBuffer, Never>()
  var framePublisher: AnyPublisher<CMSampleBuffer, Never> {
    frameSubject.eraseToAnyPublisher()
  }

  // MARK: - Properties
  private let captureSession = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "com.SDK.liveness.camera", qos: .userInteractive)
  private let videoOutput = AVCaptureVideoDataOutput()
  private let depthOutput = AVCaptureDepthDataOutput()
  private var _previewLayer: AVCaptureVideoPreviewLayer?
  private var isConfigured = false
  private var hasTrueDepth = false

  /// Reference to the face analyzer — injected so depth data can be forwarded
  var faceAnalyzer: VisionFaceAnalyzerProtocol?

  var previewLayer: AVCaptureVideoPreviewLayer? { _previewLayer }

  var authorizationStatus: AVAuthorizationStatus {
    AVCaptureDevice.authorizationStatus(for: .video)
  }

  // MARK: - Permission
  func requestPermission() async -> Bool {
    await AVCaptureDevice.requestAccess(for: .video)
  }

  // MARK: - Session Management
  func startSession() async throws {
    guard authorizationStatus == .authorized else {
      throw LivenessError.cameraPermissionDenied
    }

    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      sessionQueue.async { [weak self] in
        guard let self = self else {
          continuation.resume(throwing: LivenessError.cameraSessionFailed("Manager deallocated"))
          return
        }

        do {
          try self.configureCaptureSession()
          self.captureSession.startRunning()
          LivenessLogger.camera.info("Camera session started successfully")
          continuation.resume()
        } catch {
          LivenessLogger.camera.error("Failed to start camera: \(error.localizedDescription)")
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func stopSession() {
    sessionQueue.async { [weak self] in
      self?.captureSession.stopRunning()
      LivenessLogger.camera.info("Camera session stopped")
    }
  }

  // MARK: - Configuration
  private func configureCaptureSession() throws {
    guard !isConfigured else { return }

    captureSession.beginConfiguration()
    defer { captureSession.commitConfiguration() }

    captureSession.sessionPreset = .high

    // Try TrueDepth camera first (iPhone X and later with FaceID)
    let frontCamera: AVCaptureDevice
    if let trueDepthCamera = AVCaptureDevice.default(
      .builtInTrueDepthCamera, for: .video, position: .front)
    {
      frontCamera = trueDepthCamera
      hasTrueDepth = true
      LivenessLogger.camera.info("TrueDepth camera available — anti-spoof depth enabled")
    } else if let wideCamera = AVCaptureDevice.default(
      .builtInWideAngleCamera, for: .video, position: .front)
    {
      frontCamera = wideCamera
      hasTrueDepth = false
      LivenessLogger.camera.info("TrueDepth not available — using wide-angle, depth check bypassed")
    } else {
      throw LivenessError.cameraNotAvailable
    }

    // Configure frame rate
    try frontCamera.lockForConfiguration()
    let targetFrameRate = AppConstants.cameraFrameRate
    if let range = frontCamera.activeFormat.videoSupportedFrameRateRanges.first(where: {
      Int32($0.maxFrameRate) >= targetFrameRate
    }) {
      frontCamera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: targetFrameRate)
      frontCamera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: targetFrameRate)
      _ = range
    }
    frontCamera.unlockForConfiguration()

    // Add video input
    let input = try AVCaptureDeviceInput(device: frontCamera)
    guard captureSession.canAddInput(input) else {
      throw LivenessError.cameraSessionFailed("Cannot add camera input")
    }
    captureSession.addInput(input)

    // Add video output
    videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
    videoOutput.alwaysDiscardsLateVideoFrames = true
    videoOutput.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
    guard captureSession.canAddOutput(videoOutput) else {
      throw LivenessError.cameraSessionFailed("Cannot add video output")
    }
    captureSession.addOutput(videoOutput)

    // Add depth output (only if TrueDepth is available)
    if hasTrueDepth {
      depthOutput.setDelegate(self, callbackQueue: sessionQueue)
      depthOutput.isFilteringEnabled = true  // smooth depth data

      if captureSession.canAddOutput(depthOutput) {
        captureSession.addOutput(depthOutput)

        // Enable depth connection
        if let connection = depthOutput.connection(with: .depthData) {
          connection.isEnabled = true
        }

        LivenessLogger.camera.info("Depth data output added successfully")
      } else {
        LivenessLogger.camera.warning("Cannot add depth output to session")
        hasTrueDepth = false
      }
    }

    // Mirror front camera
    if let connection = videoOutput.connection(with: .video) {
      if connection.isVideoMirroringSupported {
        connection.isVideoMirrored = true
      }
    }

    // Create preview layer
    let preview = AVCaptureVideoPreviewLayer(session: captureSession)
    preview.videoGravity = .resizeAspectFill
    self._previewLayer = preview

    isConfigured = true
    LivenessLogger.camera.info(
      "Camera configured: \(self.hasTrueDepth ? "TrueDepth" : "wide-angle"), \(targetFrameRate)fps"
    )
  }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    frameSubject.send(sampleBuffer)
  }
}

// MARK: - AVCaptureDepthDataOutputDelegate
extension CameraManager: AVCaptureDepthDataOutputDelegate {
  func depthDataOutput(
    _ output: AVCaptureDepthDataOutput,
    didOutput depthData: AVDepthData,
    timestamp: CMTime,
    connection: AVCaptureConnection
  ) {
    // Forward depth data to the face analyzer for anti-spoof variance computation.
    // We don't have a face bounding box here — the analyzer will use a center crop.
    // The Vision analysis on the next frame will pass the real bounding box.
    faceAnalyzer?.updateDepth(depthData, faceBoundingBox: nil)
  }
}
