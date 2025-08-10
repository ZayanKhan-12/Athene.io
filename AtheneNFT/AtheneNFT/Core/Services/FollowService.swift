import Foundation

public final class FollowService {
  private var wallets = Set<String>()
  private var collections = Set<String>()
  public init() {}
  public func followWallet(_ a: String) { wallets.insert(a.lowercased()) }
  public func unfollowWallet(_ a: String) { wallets.remove(a.lowercased()) }
  public func followCollection(_ c: String) { collections.insert(c.lowercased()) }
  public func unfollowCollection(_ c: String) { collections.remove(c.lowercased()) }
  public func list() -> (wallets: [String], collections: [String]) { (Array(wallets), Array(collections)) }
}


