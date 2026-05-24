//
//  LivenessError.swift
//  SDK Liveness
//

import Foundation

/// All possible errors in the Liveness SDK
enum LivenessError: Error, Equatable {

  // MARK: - Camera
  case cameraNotAvailable
  case cameraPermissionDenied
  case cameraSessionFailed(String)

  // MARK: - Face Detection
  case noFaceDetected
  case multipleFacesDetected
  case faceNotCentered
  case faceTooFar
  case faceTooClose
  case spoofDetected

  // MARK: - Liveness Actions
  case actionTimeout(LivenessAction)
  case actionFailed(LivenessAction)

  // MARK: - Session
  case sessionTimeout
  case sessionExpired
  case maxRetriesExceeded

  // MARK: - License
  case licenseInvalid
  case licenseExpired
  case licenseNetworkError

  // MARK: - General
  case unknown(String)

  var localizedDescription: String {
    switch self {
    case .cameraNotAvailable:
      return "ไม่พบกล้องในอุปกรณ์นี้"
    case .cameraPermissionDenied:
      return "กรุณาอนุญาตให้ใช้งานกล้องเพื่อยืนยันตัวตน"
    case .cameraSessionFailed(let reason):
      return "เกิดข้อผิดพลาดกับกล้อง: \(reason)"
    case .noFaceDetected:
      return "ไม่พบใบหน้า กรุณาวางใบหน้าให้อยู่ในกรอบ"
    case .multipleFacesDetected:
      return "พบหลายใบหน้า กรุณาให้มีเพียงใบหน้าเดียวในกรอบ"
    case .faceNotCentered:
      return "กรุณาจัดใบหน้าให้อยู่ในกรอบวงรี"
    case .faceTooFar:
      return "หน้าไกลเกินไป กรุณาขยับหน้าเข้ามาใกล้ขึ้น"
    case .faceTooClose:
      return "หน้าใกล้เกินไป กรุณาขยับหน้าออกห่าง"
    case .spoofDetected:
      return "ไม่พบใบหน้า กรุณาวางใบหน้าให้อยู่ในกรอบ"
    case .actionTimeout(let action):
      return "หมดเวลาทำท่าทาง: \(action.displayName)"
    case .actionFailed(let action):
      return "ทำท่าทางไม่สำเร็จ: \(action.displayName)"
    case .sessionTimeout:
      return "หมดเวลาเนื่องจากไม่มีการตอบสนอง"
    case .sessionExpired:
      return "เซสชั่นหมดอายุ กรุณาเริ่มต้นใหม่อีกครั้ง"
    case .maxRetriesExceeded:
      return "ทำรายการเกินจำนวนครั้งที่กำหนด"
    case .licenseInvalid:
      return "SDK License ไม่ถูกต้องหรือหมดอายุ"
    case .licenseExpired:
      return "SDK License หมดอายุแล้ว"
    case .licenseNetworkError:
      return "ไม่สามารถตรวจสอบ License ได้ กรุณาตรวจสอบอินเทอร์เน็ต"
    case .unknown(let message):
      return "เกิดข้อผิดพลาดที่ไม่รู้จัก: \(message)"
    }
  }

  var errorCode: String {
    switch self {
    case .licenseInvalid: return "ERR_LICENSE_INVALID_0x403"
    case .licenseExpired: return "ERR_LICENSE_EXPIRED_0x410"
    default: return "ERR_UNKNOWN"
    }
  }
}
