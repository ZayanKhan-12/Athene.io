import SwiftUI

// MARK: - Simple Dynamic Scaling Extension
extension GeometryProxy {
    /// Get a scaling factor for dynamic UI elements based on screen width
    var scaleFactor: CGFloat {
        return min(self.size.width / 390, 1.3)
    }
    
    /// Scale any size value dynamically
    func scaled(_ value: CGFloat) -> CGFloat {
        return value * scaleFactor
    }
}

// MARK: - Simple View Extension for Dynamic UI
extension View {
    /// Apply dynamic padding that scales with screen size
    func scaledPadding(_ value: CGFloat, geometry: GeometryProxy) -> some View {
        return self.padding(geometry.scaled(value))
    }
    
    /// Apply dynamic corner radius that scales with screen size
    func scaledCornerRadius(_ value: CGFloat, geometry: GeometryProxy) -> some View {
        return self.cornerRadius(geometry.scaled(value))
    }
    
    /// Get a font that scales with screen size
    func scaledFont(size: CGFloat, weight: Font.Weight = .regular, geometry: GeometryProxy) -> some View {
        return self.font(.system(size: geometry.scaled(size), weight: weight))
    }
    
    /// Apply a frame with dynamic dimensions
    func scaledFrame(width: CGFloat? = nil, height: CGFloat? = nil, geometry: GeometryProxy) -> some View {
        return self.frame(
            width: width != nil ? geometry.scaled(width!) : nil,
            height: height != nil ? geometry.scaled(height!) : nil
        )
    }
}
