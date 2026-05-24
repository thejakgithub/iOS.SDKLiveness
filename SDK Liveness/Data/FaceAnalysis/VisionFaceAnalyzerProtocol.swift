//
//  VisionFaceAnalyzerProtocol.swift
//  SDK Liveness
//

import AVFoundation
import Combine

/// Protocol for face analysis — enables DI and testing
protocol VisionFaceAnalyzerProtocol {
    /// Publisher that emits face analysis results
    var analysisPublisher: AnyPublisher<FaceAnalysisData, Never> { get }

    /// Analyze a single camera frame
    func analyze(sampleBuffer: CMSampleBuffer)

    /// Feed depth data from TrueDepth camera for anti-spoof analysis
    func updateDepth(_ depthData: AVDepthData, faceBoundingBox: CGRect?)
}
