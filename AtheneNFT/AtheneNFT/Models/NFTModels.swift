import Foundation

struct NFT: Identifiable {
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

struct NFTUser: Identifiable {
    let id: String
    let walletAddress: String
    let username: String?
    let email: String?
    
    init(id: String = UUID().uuidString, walletAddress: String, username: String? = nil, email: String? = nil) {
        self.id = id
        self.walletAddress = walletAddress
        self.username = username
        self.email = email
    }
}
