//
//  LivenessRepositoryImpl.swift
//  SDK Liveness
//

import AVFoundation
import Combine
import os

/// Concrete implementation of LivenessRepository — connects Camera + Vision services
final class LivenessRepositoryImpl: LivenessRepositoryProtocol {

    // MARK: - Dependencies
    private let cameraManager: CameraManagerProtocol
    private let faceAnalyzer: VisionFaceAnalyzerProtocol

    // MARK: - State
    private var cancellables = Set<AnyCancellable>()

    var faceAnalysisPublisher: AnyPublisher<FaceAnalysisData, Never> {
        faceAnalyzer.analysisPublisher
    }

    var isCameraAuthorized: Bool {
        cameraManager.authorizationStatus == .authorized
    }

    // MARK: - Init
    init(cameraManager: CameraManagerProtocol, faceAnalyzer: VisionFaceAnalyzerProtocol) {
        self.cameraManager = cameraManager
        self.faceAnalyzer = faceAnalyzer
    }

    // MARK: - Methods
    func startLivenessCapture() async throws {
        // Start camera
        try await cameraManager.startSession()

        // Pipe camera frames → face analyzer
        cameraManager.framePublisher
            .sink { [weak self] sampleBuffer in
                self?.faceAnalyzer.analyze(sampleBuffer: sampleBuffer)
            }
            .store(in: &cancellables)

        LivenessLogger.session.info("Liveness capture started")
    }

    func stopLivenessCapture() {
        cancellables.removeAll()
        cameraManager.stopSession()
        LivenessLogger.session.info("Liveness capture stopped")
    }

    func requestCameraPermission() async -> Bool {
        await cameraManager.requestPermission()
    }
}
