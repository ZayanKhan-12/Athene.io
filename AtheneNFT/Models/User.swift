import Foundation

struct User: Codable, Identifiable {
    let id: String
    var username: String
    var profileImageUrl: String?
    var walletAddress: String
    var bio: String?
    var joinDate: Date
    var nftCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case profileImageUrl = "profile_image_url"
        case walletAddress = "wallet_address"
        case bio
        case joinDate = "join_date"
        case nftCount = "nft_count"
    }
}
