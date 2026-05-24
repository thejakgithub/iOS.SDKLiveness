//
//  DepthAntiSpoofAnalyzer.swift
//  SDK Liveness
//

import AVFoundation
import CoreImage
import os

/// Analyzes TrueDepth camera depth data to detect photo/screen spoofing.
///
/// A real human face is 3D — the nose protrudes, cheekbones curve, etc.
/// A printed photo or phone screen showing a face is flat (2D).
/// By measuring the **curvature** of depth values in BOTH horizontal (nose vs cheeks)
/// and vertical (nose vs forehead/chin) directions, we can reliably distinguish
/// real faces from flat spoofs, even if the photo is bent.
final class DepthAntiSpoofAnalyzer {

    // MARK: - State
    private(set) var latestResult: DepthAntiSpoofData = .unavailable
    private var isDepthAvailable = false

    // MARK: - API

    /// Called when a new depth data frame arrives from `AVCaptureDepthDataOutput`
    func processDepthData(_ depthData: AVDepthData, faceBoundingBox: CGRect?) {
        isDepthAvailable = true

        // Convert to disparity (closer = higher value) for easier math
        let convertedDepth: AVDepthData
        if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32 {
            convertedDepth = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
        } else {
            convertedDepth = depthData
        }

        let pixelBuffer = convertedDepth.depthDataMap
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            latestResult = .unknown
            return
        }

        let floatBuffer = baseAddress.assumingMemoryBound(to: Float32.self)

        // Determine the face ROI in depth image coordinates
        let roi = faceROI(from: faceBoundingBox, bufferWidth: width, bufferHeight: height)

        // We divide the ROI into a 3x3 grid to calculate both horizontal and vertical curvature.
        // For a real face, the nose is closer (higher disparity) than cheeks, forehead, and chin.
        var leftSamples: [Float32] = []
        var rightSamples: [Float32] = []
        var hCenterSamples: [Float32] = []

        var topSamples: [Float32] = []
        var bottomSamples: [Float32] = []
        var vCenterSamples: [Float32] = []

        let thirdWidth = roi.width / 3
        let leftBoundary = roi.minX + thirdWidth
        let rightBoundary = roi.minX + 2 * thirdWidth

        let thirdHeight = roi.height / 3
        let topBoundary = roi.minY + thirdHeight
        let bottomBoundary = roi.minY + 2 * thirdHeight

        for y in roi.minY..<roi.maxY {
            for x in roi.minX..<roi.maxX {
                let value = floatBuffer[y * width + x]
                if value.isFinite && value > 0 {
                    // Horizontal
                    if x < leftBoundary { leftSamples.append(value) }
                    else if x > rightBoundary { rightSamples.append(value) }
                    else { hCenterSamples.append(value) }

                    // Vertical
                    if y < topBoundary { topSamples.append(value) }
                    else if y > bottomBoundary { bottomSamples.append(value) }
                    else { vCenterSamples.append(value) }
                }
            }
        }

        guard leftSamples.count > 10, rightSamples.count > 10, hCenterSamples.count > 10,
              topSamples.count > 10, bottomSamples.count > 10, vCenterSamples.count > 10 else {
            latestResult = .unknown
            return
        }

        let meanL = leftSamples.reduce(0, +) / Float(leftSamples.count)
        let meanR = rightSamples.reduce(0, +) / Float(rightSamples.count)
        let meanHC = hCenterSamples.reduce(0, +) / Float(hCenterSamples.count)

        let meanT = topSamples.reduce(0, +) / Float(topSamples.count)
        let meanB = bottomSamples.reduce(0, +) / Float(bottomSamples.count)
        let meanVC = vCenterSamples.reduce(0, +) / Float(vCenterSamples.count)

        // Curvature: how much the center protrudes compared to the flat plane connecting the edges
        let hCurvature = meanHC - ((meanL + meanR) / 2.0)
        let vCurvature = meanVC - ((meanT + meanB) / 2.0)

        // A real face must curve in BOTH directions.
        // A bent piece of paper will only curve in one direction.
        let finalCurvature = min(hCurvature, vCurvature)

        LivenessLogger.vision.debug(
            "AntiSpoof depth curvature: H=\(hCurvature, format: .fixed(precision: 6)) V=\(vCurvature, format: .fixed(precision: 6)) min=\(finalCurvature, format: .fixed(precision: 6))"
        )
        latestResult = DepthAntiSpoofData(isDepthAvailable: true, depthCurvature: finalCurvature, isUnknown: false)
    }

    /// Called when depth data is not yet available or device doesn't support it
    func markDepthUnavailable() {
        isDepthAvailable = false
        latestResult = .unavailable
    }

    // MARK: - Helpers

    private struct IntRect {
        let minX, minY, maxX, maxY, width, height: Int
    }

    private func faceROI(from faceBoundingBox: CGRect?, bufferWidth: Int, bufferHeight: Int) -> IntRect {
        // If we have a face bounding box, crop to it (with padding); otherwise use center crop
        let roi: CGRect
        if let box = faceBoundingBox, !box.isEmpty {
            // Expand slightly for context
            let padded = box.insetBy(dx: -box.width * 0.05, dy: -box.height * 0.05)
            roi = padded.intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
        } else {
            // Center 40%×40% region
            roi = CGRect(x: 0.3, y: 0.2, width: 0.4, height: 0.5)
        }

        // Note: Vision bounding boxes are flipped vertically vs image coords
        let minX = Int(roi.minX * Double(bufferWidth)).clamped(to: 0...bufferWidth - 1)
        let maxX = Int(roi.maxX * Double(bufferWidth)).clamped(to: 0...bufferWidth)
        let minY = Int((1 - roi.maxY) * Double(bufferHeight)).clamped(to: 0...bufferHeight - 1)
        let maxY = Int((1 - roi.minY) * Double(bufferHeight)).clamped(to: 0...bufferHeight)

        return IntRect(
            minX: minX, minY: minY, maxX: maxX, maxY: maxY,
            width: maxX - minX, height: maxY - minY
        )
    }

    // Helper removed
}

// MARK: - Int clamping helper
private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
