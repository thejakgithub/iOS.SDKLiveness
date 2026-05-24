//
//  LivenessRepositoryProtocol.swift
//  SDK Liveness
//

import Combine

/// Repository interface — Domain layer depends on this protocol only
protocol LivenessRepositoryProtocol {
    /// Start camera and begin face analysis
    func startLivenessCapture() async throws

    /// Stop camera and face analysis
    func stopLivenessCapture()

    /// Publisher for face analysis data (emits every frame)
    var faceAnalysisPublisher: AnyPublisher<FaceAnalysisData, Never> { get }

    /// Request camera permission
    func requestCameraPermission() async -> Bool

    /// Check current camera permission status
    var isCameraAuthorized: Bool { get }
}
