//
//  AnimationConstants.swift
//  SDK Liveness
//

import SwiftUI

enum AnimationConstants {
    // MARK: - Durations
    static let quickTransition: Double = 0.2
    static let standardTransition: Double = 0.35
    static let slowTransition: Double = 0.6
    static let ovalColorTransition: Double = 0.4
    static let bannerSlideIn: Double = 0.3
    static let progressBarFill: Double = 0.5
    static let checkmarkAppear: Double = 0.4
    static let pulseAnimation: Double = 1.5
    static let splashDelay: Double = 2.0

    // MARK: - Springs
    static let defaultSpring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let gentleSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let bouncySpring = Animation.spring(response: 0.5, dampingFraction: 0.6)

    // MARK: - Easing
    static let easeOutQuart = Animation.timingCurve(0.25, 1, 0.5, 1, duration: standardTransition)
}
