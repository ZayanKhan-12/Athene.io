import Foundation
import SwiftUI

// MARK: - Blockchain Type
enum BlockchainType: String, Codable {
    case ethereum = "ETH"
    case solana = "SOL"
    case polygon = "MATIC"
}

// MARK: - GeometryProxy Extension
extension GeometryProxy {
    func scaled(_ value: CGFloat) -> CGFloat {
        return value * min(self.size.width / 390, 1.3)
    }
}
