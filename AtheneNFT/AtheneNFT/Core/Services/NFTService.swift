import Foundation
import SwiftUI
import Combine

// MARK: - Model Types

/// User representation for the NFT ecosystem
struct NFTUser: Identifiable, Codable, Hashable {
    let id: String
    let username: String
    let displayName: String
    let walletAddress: String
    let profileImageURL: String?
    let bio: String
    let following: [String]
    let followers: [String]
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NFTUser, rhs: NFTUser) -> Bool {
        lhs.id == rhs.id
    }
}

/// NFT item representation
struct NFTItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let imageURL: String
    let price: Double
    var creator: NFTUser
    let createdAt: Date
    let blockchainType: String
    let contract: String?
    let tokenId: String?
    var isLiked: Bool = false
    var likeCount: Int = 0
    var isCollected: Bool = false
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NFTItem, rhs: NFTItem) -> Bool {
        lhs.id == rhs.id
    }
    
    // Computed properties
    var formattedPrice: String {
        return String(format: "%.2f ETH", price)
    }
    
    var validImageURL: URL? {
        return URL(string: imageURL)
    }
    
    var isNew: Bool {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return daysSinceCreation <= 7
    }
}

/// Blockchain types supported
enum NFTBlockchainType: String {
    case ethereum = "ETH"
    case solana = "SOL"
    case polygon = "MATIC"
}

// MARK: - NFT Service

/// Service responsible for NFT-related operations including creation, fetching, and management
class NFTService: ObservableObject {
    static let shared = NFTService()
    
    @Published var trendingNFTs: [NFTItem] = []
    @Published var featuredNFTs: [NFTItem] = []
    @Published var userNFTs: [NFTItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let sampleData = SampleNFTData()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadMockData()
    }
    
    /// Creates a new NFT with the provided details
    /// - Parameters:
    ///   - title: Title of the NFT
    ///   - description: Description of the NFT
    ///   - price: Price in ETH
    ///   - image: Image data to upload
    /// - Returns: A publisher that emits the created NFT or an error
    func createNFT(title: String, description: String, price: Double, image: Data) -> AnyPublisher<NFTItem, Error> {
        // In a real implementation, this would upload to IPFS or similar storage
        // and then create an NFT on the blockchain
        
        // For now, simulate network request with delay
        return Future<NFTItem, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Create a mock NFT
                let mockUser = NFTUser(
                    id: "user123",
                    username: "current_user",
                    displayName: "Current User",
                    walletAddress: "0x123...",
                    profileImageURL: nil,
                    bio: "NFT Creator",
                    following: [],
                    followers: []
                )
                
                let nft = NFTItem(
                    id: UUID().uuidString,
                    title: title,
                    description: description,
                    imageURL: "https://example.com/image.png", // This would be the uploaded image URL
                    price: price,
                    creator: mockUser,
                    createdAt: Date(),
                    blockchainType: NFTBlockchainType.ethereum.rawValue,
                    contract: nil,
                    tokenId: nil
                )
                
                // Add to user's NFTs
                self.userNFTs.append(nft)
                
                // Return success
                promise(.success(nft))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Fetches trending NFTs
    func fetchTrendingNFTs() {
        isLoading = true
        
        // In a real app, this would be an API call
        // For now, just load mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.trendingNFTs = self.sampleData.getTrendingNFTs()
            self.isLoading = false
        }
    }
    
    /// Fetches featured NFTs
    func fetchFeaturedNFTs() {
        isLoading = true
        
        // In a real app, this would be an API call
        // For now, just load mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.featuredNFTs = self.sampleData.getFeaturedNFTs()
            self.isLoading = false
        }
    }
    
    /// Fetches NFTs for the current user
    func fetchUserNFTs() {
        isLoading = true
        
        // In a real app, this would be an API call
        // For now, just load mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.userNFTs = self.sampleData.getUserNFTs()
            self.isLoading = false
        }
    }
    
    /// Toggles the like status for an NFT
    /// - Parameter nftId: The ID of the NFT to like/unlike
    func toggleLike(for nftId: String) {
        // Update trending NFTs
        if let index = trendingNFTs.firstIndex(where: { $0.id == nftId }) {
            trendingNFTs[index].isLiked.toggle()
            trendingNFTs[index].likeCount += trendingNFTs[index].isLiked ? 1 : -1
        }
        
        // Update featured NFTs
        if let index = featuredNFTs.firstIndex(where: { $0.id == nftId }) {
            featuredNFTs[index].isLiked.toggle()
            featuredNFTs[index].likeCount += featuredNFTs[index].isLiked ? 1 : -1
        }
        
        // Update user NFTs
        if let index = userNFTs.firstIndex(where: { $0.id == nftId }) {
            userNFTs[index].isLiked.toggle()
            userNFTs[index].likeCount += userNFTs[index].isLiked ? 1 : -1
        }
    }
    
    /// Marks an NFT as collected by the current user
    /// - Parameter nftId: The ID of the NFT to collect
    func collectNFT(nftId: String) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            // Simulate network request
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Update trending NFTs
                if let index = self.trendingNFTs.firstIndex(where: { $0.id == nftId }) {
                    self.trendingNFTs[index].isCollected = true
                }
                
                // Update featured NFTs
                if let index = self.featuredNFTs.firstIndex(where: { $0.id == nftId }) {
                    self.featuredNFTs[index].isCollected = true
                }
                
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func loadMockData() {
        trendingNFTs = sampleData.getTrendingNFTs()
        featuredNFTs = sampleData.getFeaturedNFTs()
        userNFTs = sampleData.getUserNFTs()
    }
}

// MARK: - Mock Data Provider

class SampleNFTData {
    private var mockNFTs: [NFTItem] = []
    
    init() {
        createMockData()
    }
    
    func getTrendingNFTs() -> [NFTItem] {
        return Array(mockNFTs.prefix(5))
    }
    
    func getFeaturedNFTs() -> [NFTItem] {
        return Array(mockNFTs.suffix(5))
    }
    
    func getUserNFTs() -> [NFTItem] {
        return mockNFTs.filter { $0.creator.id == "user123" }
    }
    
    private func createMockData() {
        let creators = [
            NFTUser(id: "user123", username: "artistone", displayName: "Artist One", walletAddress: "0x123...", profileImageURL: nil, bio: "Digital Artist", following: [], followers: []),
            NFTUser(id: "user456", username: "artisttwo", displayName: "Artist Two", walletAddress: "0x456...", profileImageURL: nil, bio: "NFT Creator", following: [], followers: []),
            NFTUser(id: "user789", username: "artistthree", displayName: "Artist Three", walletAddress: "0x789...", profileImageURL: nil, bio: "Crypto Artist", following: [], followers: [])
        ]
        
        mockNFTs = [
            NFTItem(id: "nft1", title: "Digital Dream", description: "A surreal landscape of the digital world", imageURL: "doge_1", price: 0.5, creator: creators[0], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0xabc...", tokenId: "1"),
            NFTItem(id: "nft2", title: "Cosmic Voyage", description: "Journey through the cosmos", imageURL: "doge_2", price: 1.2, creator: creators[1], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0xdef...", tokenId: "2"),
            NFTItem(id: "nft3", title: "Future City", description: "Vision of tomorrow's metropolis", imageURL: "trending_1", price: 0.8, creator: creators[2], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0xghi...", tokenId: "3"),
            NFTItem(id: "nft4", title: "Abstract Thoughts", description: "Visualization of abstract concepts", imageURL: "trending_2", price: 0.3, creator: creators[0], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0xjkl...", tokenId: "4"),
            NFTItem(id: "nft5", title: "Nature's Embrace", description: "The beauty of the natural world", imageURL: "trending_3", price: 0.7, creator: creators[1], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0xmno...", tokenId: "5"),
            NFTItem(id: "nft6", title: "Cyberpunk Vision", description: "High-tech low-life aesthetic", imageURL: "celebrities_1", price: 1.5, creator: creators[2], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0xpqr...", tokenId: "6"),
            NFTItem(id: "nft7", title: "Serene Landscape", description: "Peaceful natural scene", imageURL: "celebrities_2", price: 0.4, creator: creators[0], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0xstu...", tokenId: "7"),
            NFTItem(id: "nft8", title: "Digital Identity", description: "Exploration of self in the digital age", imageURL: "celebrities_3", price: 0.9, creator: creators[1], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0xvwx...", tokenId: "8"),
            NFTItem(id: "nft9", title: "Blockchain Visualized", description: "Abstract representation of blockchain", imageURL: "cards_1", price: 1.0, creator: creators[2], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0xyz...", tokenId: "9"),
            NFTItem(id: "nft10", title: "Crypto Art", description: "Art inspired by cryptocurrency", imageURL: "cards_2", price: 0.6, creator: creators[0], createdAt: Date(), blockchainType: NFTBlockchainType.ethereum.rawValue, contract: "0x123abc...", tokenId: "10")
        ]
    }
}
