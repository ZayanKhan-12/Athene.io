import SwiftUI

// MARK: - View Extensions for Dynamic Sizing
extension View {
    /// Apply dynamic padding based on screen size
    func dynamicPadding(_ base: CGFloat, geometry: GeometryProxy) -> some View {
        let scaleFactor = min(geometry.size.width / 390, 1.3)
        return self.padding(base * scaleFactor)
    }
    
    /// Apply dynamic frame width based on screen size
    func dynamicWidth(_ base: CGFloat, geometry: GeometryProxy) -> some View {
        let scaleFactor = min(geometry.size.width / 390, 1.3)
        return self.frame(width: base * scaleFactor)
    }
    
    /// Apply dynamic frame height based on screen size
    func dynamicHeight(_ base: CGFloat, geometry: GeometryProxy) -> some View {
        let scaleFactor = min(geometry.size.width / 390, 1.3)
        return self.frame(height: base * scaleFactor)
    }
    
    /// Apply dynamic frame size based on screen size
    func dynamicFrame(width: CGFloat? = nil, height: CGFloat? = nil, geometry: GeometryProxy) -> some View {
        let scaleFactor = min(geometry.size.width / 390, 1.3)
        var frameWidth: CGFloat? = nil
        var frameHeight: CGFloat? = nil
        
        if let width = width {
            frameWidth = width * scaleFactor
        }
        
        if let height = height {
            frameHeight = height * scaleFactor
        }
        
        return self.frame(width: frameWidth, height: frameHeight)
    }
    
    /// Apply dynamic corner radius based on screen size
    func dynamicCornerRadius(_ radius: CGFloat, geometry: GeometryProxy) -> some View {
        let scaleFactor = min(geometry.size.width / 390, 1.3)
        return self.cornerRadius(radius * scaleFactor)
    }
    
    /// Apply dynamic font based on screen size
    func dynamicFont(size: CGFloat, weight: Font.Weight = .regular, geometry: GeometryProxy) -> some View {
        let scaleFactor = min(geometry.size.width / 390, 1.3)
        return self.font(.system(size: size * scaleFactor, weight: weight))
    }
}

// MARK: - Convenience Functions for Dynamic Values
extension GeometryProxy {
    /// Get a dynamically scaled size
    func dynamicSize(_ base: CGFloat) -> CGFloat {
        let scaleFactor = min(self.size.width / 390, 1.3)
        return base * scaleFactor
    }
    
    /// Get a dynamically scaled padding
    func dynamicPadding(_ base: CGFloat) -> CGFloat {
        let scaleFactor = min(self.size.width / 390, 1.3)
        return base * scaleFactor
    }
    
    /// Get a dynamically scaled font size
    func dynamicFontSize(_ base: CGFloat) -> CGFloat {
        let scaleFactor = min(self.size.width / 390, 1.3)
        return base * scaleFactor
    }
}
