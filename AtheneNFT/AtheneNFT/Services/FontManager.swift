import SwiftUI

/// Manages font loading and provides consistent font styles across the app
public class FontManager: ObservableObject {
    static let shared = FontManager()
    
    @Published var fontsLoaded = false
    
    // MARK: - Font Names
    let primaryFontFamily = "Noto Sans"
    let secondaryFontFamily = "System"
    
    private init() {
        loadCustomFonts()
    }
    
    private func loadCustomFonts() {
        // In a real app, you would dynamically register custom fonts here
        DispatchQueue.main.async {
            self.fontsLoaded = true
        }
    }
    
    // MARK: - Common Font Styles
    
    /// Returns a primary font with the specified size and weight
    func primaryFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if fontsLoaded {
            return Font.custom(primaryFontFamily, size: size).weight(weight)
        } else {
            return .system(size: size, weight: weight)
        }
    }
    
    /// Returns a title font
    func titleFont(size: CGFloat = 24) -> Font {
        if fontsLoaded {
            return Font.custom(primaryFontFamily, size: size).weight(.bold)
        } else {
            return .system(size: size, weight: .bold)
        }
    }
    
    /// Returns a subtitle font
    func subtitleFont(size: CGFloat = 18) -> Font {
        if fontsLoaded {
            return Font.custom(primaryFontFamily, size: size).weight(.semibold)
        } else {
            return .system(size: size, weight: .semibold)
        }
    }
    
    /// Returns a body text font
    func bodyFont(size: CGFloat = 16) -> Font {
        if fontsLoaded {
            return Font.custom(primaryFontFamily, size: size).weight(.regular)
        } else {
            return .system(size: size, weight: .regular)
        }
    }
    
    /// Returns a caption font
    func captionFont(size: CGFloat = 12) -> Font {
        if fontsLoaded {
            return Font.custom(primaryFontFamily, size: size).weight(.medium)
        } else {
            return .system(size: size, weight: .medium)
        }
    }
    
    // MARK: - Responsive Font Sizes
    
    /// Returns a font that scales based on screen size
    func responsiveFont(baseSize: CGFloat, geometry: GeometryProxy, weight: Font.Weight = .regular) -> Font {
        let scaleFactor = min(geometry.size.width / 390, 1.3)
        let responsiveSize = baseSize * scaleFactor
        
        if fontsLoaded {
            return Font.custom(primaryFontFamily, size: responsiveSize).weight(weight)
        } else {
            return .system(size: responsiveSize, weight: weight)
        }
    }
    
    // MARK: - Dynamic Sizing Helpers
    
    /// Calculates a font size that scales with the device size
    func fontSize(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    /// Calculates a size that scales with the device size
    func size(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    /// Calculates padding that scales with the device size
    func padding(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    /// Calculates spacing that scales with the device size
    func spacing(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
}
