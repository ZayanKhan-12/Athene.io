import Foundation

enum FeedEventType: String, Codable, Hashable { case listed, sold, offer, transfer, metadata }

struct FeedItem: Identifiable, Hashable, Codable {
    let id: String
    let ts: Date
    let type: FeedEventType
    let collectionSlug: String
    let contract: String
    let tokenId: String
    let priceEth: Double?
    let owner: String?
    let mediaURL: URL?
}

struct CollectionFloorSnapshot: Hashable, Codable {
    let slug: String
    let floorEth: Double?
    let updatedAt: Date
}

struct FeedStreamEvent: Codable, Hashable, Identifiable {
    let id: String
    let ts: Date
    let type: FeedEventType
    let collectionSlug: String
    let contract: String
    let tokenId: String
    let priceWei: String?
    let owner: String?
    let mediaURL: URL?

    var priceEth: Double? { priceWei.flatMap(Double.init).map { $0 / 1e18 } }
}

extension FollowService {
    func followedCollections() -> [String] { list().collections }
    func followsOwner(_ address: String) -> Bool { list().wallets.contains(address.lowercased()) }
    func followsCollection(_ slug: String) -> Bool { list().collections.contains(slug.lowercased()) }
    func friendOfFollow(_ address: String) -> Bool { false }
}


