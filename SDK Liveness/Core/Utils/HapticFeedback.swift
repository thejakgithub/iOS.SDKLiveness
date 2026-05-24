//
//  HapticFeedback.swift
//  SDK Liveness
//

import UIKit

enum HapticFeedback {
    /// Light tap — face detected
    static func faceDetected() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium tap — action completed
    static func actionCompleted() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Success notification — verification passed
    static func verificationSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Error notification — verification failed
    static func verificationFailed() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    /// Warning notification — timeout
    static func sessionTimeout() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
