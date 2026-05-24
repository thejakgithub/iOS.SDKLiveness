//
//  CameraPermissionViewModel.swift
//  SDK Liveness
//

import SwiftUI
import AVFoundation
import Combine

@MainActor
final class CameraPermissionViewModel: ObservableObject {

    enum PermissionState {
        case notDetermined
        case authorized
        case denied
    }

    @Published var state: PermissionState = .notDetermined

    private let repository: LivenessRepositoryProtocol

    init(repository: LivenessRepositoryProtocol) {
        self.repository = repository
        updateState()
    }

    func requestPermission() async {
        let granted = await repository.requestCameraPermission()
        state = granted ? .authorized : .denied
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func updateState() {
        if repository.isCameraAuthorized {
            state = .authorized
        } else {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:    state = .authorized
            case .denied, .restricted: state = .denied
            default:             state = .notDetermined
            }
        }
    }
}
