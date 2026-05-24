//
//  LivenessAction.swift
//  SDK Liveness
//

import Foundation

/// The 4 liveness actions that must be performed
enum LivenessAction: String, CaseIterable, Equatable, Identifiable {
  case turnLeft
  case turnRight
  case blink
  case smile
  case nod

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .turnLeft: return "หันหน้าไปทางซ้าย"
    case .turnRight: return "หันหน้าไปทางขวา"
    case .blink: return "กระพริบตา"
    case .smile: return "ยิ้ม"
    case .nod: return "พยักหน้า"
    }
  }

  var instruction: String {
    switch self {
    case .turnLeft: return "ค่อยๆ หันหน้าไปทางซ้าย"
    case .turnRight: return "ค่อยๆ หันหน้าไปทางขวา"
    case .blink: return "กระพริบตาให้เป็นธรรมชาติ"
    case .smile: return "ยิ้มกว้างให้เห็นฟันเล็กน้อย"
    case .nod: return "พยักหน้าลงช้าๆ"
    }
  }

  var iconSymbol: String {
    switch self {
    case .turnLeft: return "←"
    case .turnRight: return "→"
    case .blink: return "👁️"
    case .smile: return "😊"
    case .nod: return "↓"
    }
  }
}
