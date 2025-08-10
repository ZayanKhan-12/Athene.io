import Foundation

public enum FeedEventType: String, Codable, CaseIterable, Hashable {
    case listed, sold, offer, transfer, metadata
}

public struct FeedStreamEvent: Identifiable, Codable, Hashable {
    public let id: String                 // txHash or "contract#tokenId#epoch"
    public let ts: Date
    public let type: FeedEventType
    public let collectionSlug: String
    public let contract: String
    public let tokenId: String
    public let priceWei: String?
    public let owner: String?
    public let mediaURL: URL?

    public init(
        id: String,
        ts: Date,
        type: FeedEventType,
        collectionSlug: String,
        contract: String,
        tokenId: String,
        priceWei: String?,
        owner: String?,
        mediaURL: URL?
    ) {
        self.id = id
        self.ts = ts
        self.type = type
        self.collectionSlug = collectionSlug
        self.contract = contract
        self.tokenId = tokenId
        self.priceWei = priceWei
        self.owner = owner
        self.mediaURL = mediaURL
    }
}

public extension FeedStreamEvent {
    var priceEth: Double? {
        guard let w = priceWei, let d = Double(w) else { return nil }
        return d / 1e18
    }

    static func makeFallbackId(contract: String, tokenId: String, timestamp: Date) -> String {
        "\(contract)#\(tokenId)#\(Int(timestamp.timeIntervalSince1970))"
    }
}


