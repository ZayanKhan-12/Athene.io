import SwiftUI

/// Extension to provide dynamic sizing based on screen size
public extension GeometryProxy {
    /// Returns a scaling factor for dynamic UI elements
    var scalingFactor: CGFloat {
        min(self.size.width / 390, 1.3)
    }
    
    /// Returns a value scaled based on the device screen size
    func scaled(_ value: CGFloat) -> CGFloat {
        value * scalingFactor
    }
    
    /// Returns a scaled font size
    func scaledFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: scaled(baseSize), weight: weight)
    }
}

/// Extension for applying dynamic sizes to views
public extension View {
    /// Apply padding that scales with screen size
    func dynamicPadding(_ value: CGFloat, geometry: GeometryProxy) -> some View {
        self.padding(geometry.scaled(value))
    }
    
    /// Apply a font that scales with screen size
    func dynamicFont(size: CGFloat, weight: Font.Weight = .regular, geometry: GeometryProxy) -> some View {
        self.font(geometry.scaledFont(size, weight: weight))
    }
    
    /// Apply a frame size that scales with screen size
    func dynamicFrame(width: CGFloat? = nil, height: CGFloat? = nil, geometry: GeometryProxy) -> some View {
        self.frame(
            width: width.map { geometry.scaled($0) },
            height: height.map { geometry.scaled($0) }
        )
    }
    
    /// Apply a corner radius that scales with screen size
    func dynamicCornerRadius(_ value: CGFloat, geometry: GeometryProxy) -> some View {
        self.cornerRadius(geometry.scaled(value))
    }
}
