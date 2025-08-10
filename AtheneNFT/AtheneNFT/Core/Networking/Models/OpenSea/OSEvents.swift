import Foundation

struct OSEventsResponse: Codable { let events: [OSEvent]; let next: String? }

struct OSEvent: Codable {
    let event_type: String?
    let collection_slug: String?
    let contract_address: String?
    let token_id: String?
    let from_account: String?
    let to_account: String?
    let price: String?
    let created_date: String?
}

extension OSEvent {
    func toFeedItem() -> FeedItem? {
        guard let slug = collection_slug, let contract = contract_address, let tokenId = token_id else { return nil }
        let date = created_date.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()
        let type = mapType(event_type)
        let owner = to_account ?? from_account
        let priceEth = price.flatMap { Double($0) }.map { $0 / 1e18 }
        let id = "\(contract.lowercased())#\(tokenId)#\(Int(date.timeIntervalSince1970))"
        return FeedItem(id: id, ts: date, type: type, collectionSlug: slug, contract: contract.lowercased(), tokenId: tokenId, priceEth: priceEth, owner: owner?.lowercased(), mediaURL: nil)
    }

    private func mapType(_ raw: String?) -> FeedEventType {
        let k = (raw ?? "").lowercased()
        if k.contains("list") { return .listed }
        if k.contains("offer") || k.contains("bid") { return .offer }
        if k.contains("sale") || k.contains("sell") || k.contains("match") { return .sold }
        if k.contains("transfer") { return .transfer }
        return .metadata
    }
}


