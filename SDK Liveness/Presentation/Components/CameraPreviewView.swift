//
//  CameraPreviewView.swift
//  SDK Liveness
//

import AVFoundation
import SwiftUI

class VideoPreviewView: UIView {
  var previewLayer: AVCaptureVideoPreviewLayer? {
    didSet {
      oldValue?.removeFromSuperlayer()
      if let previewLayer = previewLayer {
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        previewLayer.frame = bounds
      }
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    previewLayer?.frame = bounds
  }
}

/// UIViewRepresentable wrapper for AVCaptureVideoPreviewLayer
struct CameraPreviewView: UIViewRepresentable {
  let previewLayer: AVCaptureVideoPreviewLayer?

  func makeUIView(context: Context) -> VideoPreviewView {
    let view = VideoPreviewView()
    view.backgroundColor = .clear
    view.previewLayer = previewLayer
    return view
  }

  func updateUIView(_ uiView: VideoPreviewView, context: Context) {
    if uiView.previewLayer !== previewLayer {
      uiView.previewLayer = previewLayer
    }
  }
}
