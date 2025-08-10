import Foundation

@MainActor
final class SocialService: ObservableObject {
    static let shared = SocialService()

    @Published private(set) var likesByNFT: [String: Int] = [:] // key: contract:tokenId
    @Published private(set) var didLikeByUser: Set<String> = [] // composite key: userId|nftKey
    @Published private(set) var commentsByNFT: [String: [Comment]] = [:]
    @Published private(set) var followingWallets: Set<String> = []

    struct Comment: Identifiable, Hashable {
        let id: String = UUID().uuidString
        let userId: String
        let text: String
        let timestamp: Date = Date()
    }

    private init() {}

    func toggleLike(nftKey: String, userId: String) {
        let composite = "\(userId)|\(nftKey)"
        if didLikeByUser.contains(composite) {
            didLikeByUser.remove(composite)
            likesByNFT[nftKey, default: 0] = max(likesByNFT[nftKey, default: 0] - 1, 0)
        } else {
            didLikeByUser.insert(composite)
            likesByNFT[nftKey, default: 0] += 1
        }
    }

    func addComment(nftKey: String, userId: String, text: String) {
        var arr = commentsByNFT[nftKey, default: []]
        arr.append(Comment(userId: userId, text: text))
        commentsByNFT[nftKey] = arr
    }

    func follow(walletAddress: String) {
        followingWallets.insert(walletAddress.lowercased())
    }

    func unfollow(walletAddress: String) {
        followingWallets.remove(walletAddress.lowercased())
    }

    func isFollowing(_ walletAddress: String) -> Bool { followingWallets.contains(walletAddress.lowercased()) }

    func toggleFollow(walletAddress: String) {
        let addr = walletAddress.lowercased()
        if followingWallets.contains(addr) {
            followingWallets.remove(addr)
        } else {
            followingWallets.insert(addr)
        }
    }
}


