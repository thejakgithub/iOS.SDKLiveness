//
//  CameraManagerProtocol.swift
//  SDK Liveness
//

import AVFoundation
import Combine

/// Protocol for camera management — enables DI and testing
protocol CameraManagerProtocol {
    /// Publisher that emits camera frames
    var framePublisher: AnyPublisher<CMSampleBuffer, Never> { get }

    /// Current camera authorization status
    var authorizationStatus: AVAuthorizationStatus { get }

    /// Start the camera session
    func startSession() async throws

    /// Stop the camera session
    func stopSession()

    /// Request camera permission
    func requestPermission() async -> Bool

    /// Get the preview layer for UI display
    var previewLayer: AVCaptureVideoPreviewLayer? { get }
}
