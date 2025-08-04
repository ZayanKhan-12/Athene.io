import SwiftUI

// A base protocol to avoid import errors
protocol ViewBase { }

// Global extension for GeometryProxy that can be used everywhere
extension GeometryProxy {
    func scaled(_ value: CGFloat) -> CGFloat {
        return value * min(self.size.width / 390, 1.3)
    }
}
