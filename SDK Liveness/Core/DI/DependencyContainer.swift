//
//  DependencyContainer.swift
//  SDK Liveness
//

import Foundation
import Combine

/// Simple dependency injection container for the Liveness SDK
@MainActor
final class DependencyContainer: ObservableObject {

    // MARK: - Data Layer
    lazy var cameraManager: CameraManagerProtocol = {
        let manager = CameraManager()
        manager.faceAnalyzer = faceAnalyzer
        return manager
    }()
    lazy var faceAnalyzer: VisionFaceAnalyzerProtocol = VisionFaceAnalyzer()
    lazy var licenseValidator: LicenseValidatorProtocol = LicenseValidator()

    // MARK: - Repository
    lazy var livenessRepository: LivenessRepositoryProtocol = LivenessRepositoryImpl(
        cameraManager: cameraManager,
        faceAnalyzer: faceAnalyzer
    )

    // MARK: - Use Cases
    lazy var detectFaceUseCase = DetectFaceUseCase()
    lazy var validateHeadTurnUseCase = ValidateHeadTurnUseCase()
    lazy var validateBlinkUseCase = ValidateBlinkUseCase()
    lazy var validateSmileUseCase = ValidateSmileUseCase()
    lazy var validateNodUseCase = ValidateNodUseCase()

    lazy var runLivenessSessionUseCase = RunLivenessSessionUseCase(
        detectFaceUseCase: detectFaceUseCase,
        validateHeadTurnUseCase: validateHeadTurnUseCase,
        validateBlinkUseCase: validateBlinkUseCase,
        validateSmileUseCase: validateSmileUseCase,
        validateNodUseCase: validateNodUseCase
    )

    lazy var validateLicenseUseCase = ValidateLicenseUseCase(
        licenseValidator: licenseValidator
    )

    // MARK: - View Models
    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel(validateLicenseUseCase: validateLicenseUseCase)
    }

    func makeCameraPermissionViewModel() -> CameraPermissionViewModel {
        CameraPermissionViewModel(repository: livenessRepository)
    }

    func makeLivenessViewModel() -> LivenessViewModel {
        LivenessViewModel(
            repository: livenessRepository,
            runSessionUseCase: runLivenessSessionUseCase,
            cameraManager: cameraManager
        )
    }

    func makeResultViewModel(result: LivenessResult) -> ResultViewModel {
        ResultViewModel(result: result)
    }
}
