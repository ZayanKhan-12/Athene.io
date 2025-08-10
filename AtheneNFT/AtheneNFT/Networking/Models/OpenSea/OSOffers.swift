import Foundation

struct OSOffersResponse: Codable { let orders: [OSOffer]?; let next: String? }

struct OSOffer: Codable {
    let price: String?
}

extension OSOffersResponse {
    func bestBidEth() -> Double? {
        guard let orders, let first = orders.first else { return nil }
        if let p = first.price, let v = Double(p) { return v / 1e18 }
        return nil
    }
}


