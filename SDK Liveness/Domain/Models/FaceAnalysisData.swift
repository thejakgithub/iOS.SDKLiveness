//
//  FaceAnalysisData.swift
//  SDK Liveness
//

import Foundation
import CoreGraphics

/// Combined face analysis result from Vision framework — passed from Data layer to Domain layer
struct FaceAnalysisData: Equatable {
    /// Head pose (yaw, pitch, roll) in degrees
    let headPose: HeadPose

    /// Eye blink state (EAR values)
    let eyeState: EyeState

    /// Smile detection state (lip ratio)
    let smileState: SmileState

    /// Face bounding box in normalized coordinates (0-1)
    let faceBoundingBox: CGRect

    /// Confidence of face detection (0-1)
    let faceConfidence: Float

    /// Whether a face was detected at all
    let isFaceDetected: Bool

    /// Timestamp of the analysis
    let timestamp: TimeInterval

    /// TrueDepth anti-spoof result (unavailable on non-FaceID devices)
    let depthAntiSpoof: DepthAntiSpoofData

    static let empty = FaceAnalysisData(
        headPose: .zero,
        eyeState: .defaultOpen,
        smileState: .neutral,
        faceBoundingBox: .zero,
        faceConfidence: 0,
        isFaceDetected: false,
        timestamp: 0,
        depthAntiSpoof: .unavailable
    )
}

