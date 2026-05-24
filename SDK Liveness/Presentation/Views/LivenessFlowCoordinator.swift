//
//  LivenessFlowCoordinator.swift
//  SDK Liveness
//

import SwiftUI

/// Navigation coordinator for the liveness verification flow
struct LivenessFlowCoordinator: View {
    @StateObject private var container = DependencyContainer()

    enum FlowScreen {
        case splash
        case cameraPermission
        case liveness
        case success(String)  // sessionId
        case failed
        case timeout
        case licenseError(String) // errorCode
    }

    @State private var currentScreen: FlowScreen = .splash

    var body: some View {
        ZStack {
            switch currentScreen {
            case .splash:
                splashScreen
                    .transition(.opacity)

            case .cameraPermission:
                cameraPermissionScreen
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .liveness:
                livenessScreen
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            case .success(let sessionId):
                VerificationSuccessView(sessionId: sessionId) {
                    withAnimation { currentScreen = .splash }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))

            case .failed:
                VerificationFailedView(
                    onTryAgain: {
                        withAnimation { currentScreen = .liveness }
                    },
                    onGetHelp: {
                        // TODO: Open help URL or support contact
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))

            case .timeout:
                SessionTimeoutView {
                    withAnimation { currentScreen = .liveness }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))

            case .licenseError(let code):
                LicenseErrorView(errorCode: code) {
                    // TODO: Open support URL
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: AnimationConstants.standardTransition), value: screenId)
    }

    // MARK: - Screen Builders

    private var splashScreen: some View {
        let vm = container.makeSplashViewModel()
        return SplashView(viewModel: vm)
            .onReceive(vm.$state) { state in
                switch state {
                case .licenseValid:
                    withAnimation { currentScreen = .cameraPermission }
                case .licenseError(let error):
                    withAnimation { currentScreen = .licenseError(error.errorCode) }
                default:
                    break
                }
            }
    }

    private var cameraPermissionScreen: some View {
        let vm = container.makeCameraPermissionViewModel()
        return CameraPermissionView(viewModel: vm)
            .onReceive(vm.$state) { state in
                if state == .authorized {
                    withAnimation { currentScreen = .liveness }
                }
            }
    }

    private var livenessScreen: some View {
        let vm = container.makeLivenessViewModel()
        return LivenessView(viewModel: vm)
            .onReceive(vm.$sessionState) { state in
                switch state {
                case .verificationPassed:
                    let sessionId = vm.livenessResult?.sessionId ?? "N/A"
                    withAnimation { currentScreen = .success(sessionId) }
                case .verificationFailed:
                    withAnimation { currentScreen = .failed }
                case .sessionTimeout:
                    withAnimation { currentScreen = .timeout }
                default:
                    break
                }
            }
    }

    // MARK: - Helper
    private var screenId: String {
        switch currentScreen {
        case .splash: return "splash"
        case .cameraPermission: return "permission"
        case .liveness: return "liveness"
        case .success: return "success"
        case .failed: return "failed"
        case .timeout: return "timeout"
        case .licenseError: return "licenseError"
        }
    }
}
