//
//  SplashViewModel.swift
//  SDK Liveness
//

import SwiftUI
import Combine

@MainActor
final class SplashViewModel: ObservableObject {

    enum SplashState {
        case loading
        case licenseValid
        case licenseError(LivenessError)
    }

    @Published var state: SplashState = .loading

    private let validateLicenseUseCase: ValidateLicenseUseCase

    init(validateLicenseUseCase: ValidateLicenseUseCase) {
        self.validateLicenseUseCase = validateLicenseUseCase
    }

    func checkLicense() async {
        state = .loading

        // Delay for splash screen display
        try? await Task.sleep(nanoseconds: UInt64(AnimationConstants.splashDelay * 1_000_000_000))

        let result = await validateLicenseUseCase.execute()
        switch result {
        case .success:
            state = .licenseValid
        case .failure(let error):
            state = .licenseError(error)
        }
    }
}
