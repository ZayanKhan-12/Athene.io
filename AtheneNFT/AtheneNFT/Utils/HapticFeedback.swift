import SwiftUI

// Cross-platform haptic feedback utility
struct HapticFeedback {
    static func impact(style: FeedbackStyle = .medium) {
        #if os(iOS)
        if #available(iOS 13.0, *) {
            let generator: UIImpactFeedbackGenerator
            
            switch style {
            case .light:
                generator = UIImpactFeedbackGenerator(style: .light)
            case .medium:
                generator = UIImpactFeedbackGenerator(style: .medium)
            case .heavy:
                generator = UIImpactFeedbackGenerator(style: .heavy)
            case .soft:
                if #available(iOS 13.0, *) {
                    generator = UIImpactFeedbackGenerator(style: .soft)
                } else {
                    generator = UIImpactFeedbackGenerator(style: .light)
                }
            case .rigid:
                if #available(iOS 13.0, *) {
                    generator = UIImpactFeedbackGenerator(style: .rigid)
                } else {
                    generator = UIImpactFeedbackGenerator(style: .medium)
                }
            }
            
            generator.prepare()
            generator.impactOccurred()
        }
        #endif
    }
    
    // Selection feedback
    static func selection() {
        #if os(iOS)
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
        #endif
    }
    
    // Notification feedback
    static func notification(type: NotificationType = .success) {
        #if os(iOS)
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            
            switch type {
            case .success:
                generator.notificationOccurred(.success)
            case .warning:
                generator.notificationOccurred(.warning)
            case .error:
                generator.notificationOccurred(.error)
            }
        }
        #endif
    }
    
    // Feedback styles
    enum FeedbackStyle {
        case light
        case medium
        case heavy
        case soft   // iOS 13+
        case rigid  // iOS 13+
    }
    
    // Notification types
    enum NotificationType {
        case success
        case warning
        case error
    }
}
