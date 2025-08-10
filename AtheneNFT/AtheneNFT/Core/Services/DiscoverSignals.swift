import Foundation

public struct DiscoverItem: Identifiable, Hashable {
  public let id = UUID()
  public let collection: String
  public let volume24h: Double
  public let floorDelta24h: Double
  public let recentListings: Int
}

public enum DiscoverSignals {
  public static func rank(_ items: [DiscoverItem]) -> [DiscoverItem] {
    func z(_ xs: [Double], _ x: Double) -> Double {
      guard let m = xs.average, let s = xs.std, s > 0 else { return 0 }
      return (x - m)/s
    }
    let vols = items.map{$0.volume24h}, deltas = items.map{$0.floorDelta24h}, recents = items.map{Double($0.recentListings)}
    return items.sorted { a, b in
      let sa = 0.5*z(vols,a.volume24h) + 0.3*z(deltas,a.floorDelta24h) + 0.2*z(recents,Double(a.recentListings))
      let sb = 0.5*z(vols,b.volume24h) + 0.3*z(deltas,b.floorDelta24h) + 0.2*z(recents,Double(b.recentListings))
      return sa > sb
    }
  }
}

private extension Array where Element == Double {
  var average: Double? { isEmpty ? nil : reduce(0,+)/Double(count) }
  var std: Double? {
    guard let m = average, !isEmpty else { return nil }
    return sqrt(reduce(0){$0 + pow($1 - m, 2)} / Double(count))
  }
}


