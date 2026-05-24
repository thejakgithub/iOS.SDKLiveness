//
//  LicenseValidator.swift
//  SDK Liveness
//

import Foundation

/// License validation (placeholder — implement actual logic later)
protocol LicenseValidatorProtocol {
    func validateLicense() async -> Result<Bool, LivenessError>
}

final class LicenseValidator: LicenseValidatorProtocol {
    // TODO: Implement actual license validation logic
    // For now, always returns valid

    func validateLicense() async -> Result<Bool, LivenessError> {
        // Simulate a small delay for license check
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        return .success(true)
    }
}
