//
//  LivenessSessionConfig.swift
//  SDK Liveness
//

import Foundation

/// Configuration for a liveness verification session
struct LivenessSessionConfig {
    /// Ordered list of actions to perform
    let actions: [LivenessAction]

    /// Session timeout in seconds
    let timeoutSeconds: TimeInterval

    /// Maximum retry attempts for the entire session
    let maxRetries: Int

    /// Whether to randomize action order
    let randomizeOrder: Bool

    /// Default configuration with all 4 actions, randomized
    static let `default` = LivenessSessionConfig(
        actions: [.turnLeft, .blink, .smile, .nod].shuffled(),
        timeoutSeconds: AppConstants.sessionTimeoutSeconds,
        maxRetries: AppConstants.maxRetryAttempts,
        randomizeOrder: true
    )

    /// Create a session config, optionally randomizing action order
    func withRandomizedOrder() -> LivenessSessionConfig {
        LivenessSessionConfig(
            actions: actions.shuffled(),
            timeoutSeconds: timeoutSeconds,
            maxRetries: maxRetries,
            randomizeOrder: true
        )
    }
}
