import Foundation
import SwiftUI

// This file is deprecated - using the unified models in NFT.swift and User.swift
// Keeping this file as a compatibility layer

// Simple NFT struct for backward compatibility
struct NFTSimple: Identifiable {
    let id: String
    let name: String
    let description: String
    let imageUrl: String
    let price: Double
    let creator: String
    let tokenId: String
    let contractAddress: String
    var likes: Int = 0
    
    var priceString: String {
        return String(format: "%.2f ETH", price)
    }
}
