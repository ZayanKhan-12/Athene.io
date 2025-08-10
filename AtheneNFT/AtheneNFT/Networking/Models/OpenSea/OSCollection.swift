import Foundation

struct OSCollectionResponse: Codable {
    let collection: OSCollection?
}

struct OSCollection: Codable {
    let slug: String?
    let stats: OSStats?
}

struct OSStats: Codable {
    let floor_price: Double?
}

extension OSCollectionResponse {
    func toSnapshot() -> CollectionFloorSnapshot? {
        guard let c = collection else { return nil }
        return CollectionFloorSnapshot(slug: c.slug ?? "", floorEth: c.stats?.floor_price, updatedAt: Date())
    }
}


