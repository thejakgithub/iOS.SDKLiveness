//
//  VNFaceObservation+HeadPose.swift
//  SDK Liveness
//

import Vision

extension VNFaceObservation {
    /// Yaw angle in degrees (positive = looking left, negative = looking right)
    var yawDegrees: Double {
        guard let yaw = self.yaw else { return 0 }
        return yaw.doubleValue * 180.0 / .pi
    }

    /// Pitch angle in degrees (positive = looking up, negative = looking down)
    var pitchDegrees: Double {
        guard let pitch = self.pitch else { return 0 }
        return pitch.doubleValue * 180.0 / .pi
    }

    /// Roll angle in degrees (positive = tilting right, negative = tilting left)
    var rollDegrees: Double {
        guard let roll = self.roll else { return 0 }
        return roll.doubleValue * 180.0 / .pi
    }

    /// HeadPose from VNFaceObservation
    var headPose: HeadPose {
        HeadPose(
            yaw: yawDegrees,
            pitch: pitchDegrees,
            roll: rollDegrees
        )
    }
}
