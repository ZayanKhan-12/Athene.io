import Foundation

struct OSListingsResponse: Codable { let orders: [OSListing]?; let next: String? }

struct OSListing: Codable {
    let price: String?
    struct ProtocolData: Codable { struct Parameters: Codable { let consideration: [Consideration]?; struct Consideration: Codable { let startAmount: String? } }; let parameters: Parameters? }
    let protocol_data: ProtocolData?
}

extension OSListingsResponse {
    func bestPriceEth() -> Double? {
        guard let orders, let first = orders.first else { return nil }
        if let p = first.price, let v = Double(p) { return v / 1e18 }
        if let amt = first.protocol_data?.parameters?.consideration?.first?.startAmount, let v = Double(amt) { return v / 1e18 }
        return nil
    }
}


