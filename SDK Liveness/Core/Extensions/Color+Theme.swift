//
//  Color+Theme.swift
//  SDK Liveness
//

import SwiftUI

extension Color {
  // MARK: - SDKLiveness Theme Colors

  /// Dark navy background - #0D0D1A
  static let SDKBackground = Color(red: 13 / 255, green: 13 / 255, blue: 26 / 255)

  /// Primary purple - #6C63FF
  static let SDKPrimary = Color(red: 108 / 255, green: 99 / 255, blue: 255 / 255)

  /// Success green - #00E676
  static let SDKSuccess = Color(red: 0 / 255, green: 230 / 255, blue: 118 / 255)

  /// Warning orange - #FFA726
  static let SDKWarning = Color(red: 255 / 255, green: 167 / 255, blue: 38 / 255)

  /// Error red - #FF5252
  static let SDKError = Color(red: 255 / 255, green: 82 / 255, blue: 82 / 255)

  /// Card/container dark slate - #1A1A3E
  static let SDKCardBackground = Color(red: 26 / 255, green: 26 / 255, blue: 62 / 255)

  /// Muted lavender text - #9E9EB8
  static let SDKTextSecondary = Color(red: 158 / 255, green: 158 / 255, blue: 184 / 255)

  /// Deep purple for success icon bg - #1B5E20 with dark tint
  static let SDKSuccessBackground = Color(red: 27 / 255, green: 94 / 255, blue: 32 / 255).opacity(
    0.4)

  /// Deep red for error icon bg
  static let SDKErrorBackground = Color(red: 183 / 255, green: 28 / 255, blue: 28 / 255).opacity(
    0.4)

  /// Deep orange for timeout icon bg
  static let SDKWarningBackground = Color(red: 230 / 255, green: 126 / 255, blue: 34 / 255).opacity(
    0.3)
}
