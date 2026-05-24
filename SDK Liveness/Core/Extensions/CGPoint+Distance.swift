//
//  CGPoint+Distance.swift
//  SDK Liveness
//

import CoreGraphics

extension CGPoint {
    /// Calculate Euclidean distance between two points
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }

    /// Calculate midpoint between two points
    func midpoint(to point: CGPoint) -> CGPoint {
        CGPoint(x: (self.x + point.x) / 2, y: (self.y + point.y) / 2)
    }
}
