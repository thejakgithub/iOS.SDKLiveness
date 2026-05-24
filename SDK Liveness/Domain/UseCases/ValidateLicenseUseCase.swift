//
//  ValidateLicenseUseCase.swift
//  SDK Liveness
//

import Foundation

/// Validates SDK license
final class ValidateLicenseUseCase {

    private let licenseValidator: LicenseValidatorProtocol

    init(licenseValidator: LicenseValidatorProtocol) {
        self.licenseValidator = licenseValidator
    }

    func execute() async -> Result<Bool, LivenessError> {
        await licenseValidator.validateLicense()
    }
}
