import SwiftUI

/// A unified scaling factor that can be used even without GeometryReader
public struct DynamicScaling {
    /// Default scaling based on common device width
    public static func scale(for width: CGFloat) -> CGFloat {
        return min(width / 390, 1.3)
    }
    
    /// Scale a value for a given width
    public static func scaled(_ value: CGFloat, for width: CGFloat) -> CGFloat {
        return value * scale(for: width)
    }
    
    /// Get a scaled font for a width
    public static func font(size: CGFloat, weight: Font.Weight = .regular, for width: CGFloat) -> Font {
        return .system(size: scaled(size, for: width), weight: weight)
    }
}

/// A simplified NFT model that works without dependencies
public struct SimpleNFT: Identifiable {
    public var id = UUID()
    public var name: String
    public var imageUrl: String
    public var price: String
    public var likes: Int
    
    public init(name: String = "NFT", imageUrl: String = "", price: String = "0.05 ETH", likes: Int = 0) {
        self.name = name
        self.imageUrl = imageUrl
        self.price = price
        self.likes = likes
    }
}

/// A simplified user model that works without dependencies
public struct SimpleUser: Identifiable {
    public var id = UUID()
    public var username: String
    public var walletAddress: String
    
    public init(username: String = "User", walletAddress: String = "0x1234...5678") {
        self.username = username
        self.walletAddress = walletAddress
    }
}
