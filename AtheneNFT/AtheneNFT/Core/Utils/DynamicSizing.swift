import SwiftUI

// MARK: - Dynamic Sizing Helper
struct DynamicSizing {
    /// Calculate font size based on screen width
    static func fontSize(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    /// Calculate view size based on screen width
    static func size(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    /// Calculate padding based on screen width
    static func padding(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    /// Calculate spacing based on screen width
    static func spacing(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
}
