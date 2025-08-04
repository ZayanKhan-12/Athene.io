import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: String
    let walletAddress: String
    var username: String?
    var displayName: String
    var displayUsername: String
    var email: String?
    var profileImageURL: String?
    var bio: String?
    var following: [String]
    var followers: [String]
    let createdAt: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: String = UUID().uuidString, walletAddress: String, username: String? = nil, email: String? = nil) {
        self.id = id
        self.walletAddress = walletAddress
        self.username = username
        self.displayName = username ?? "Unnamed"
        self.displayUsername = "@\(username?.lowercased().replacingOccurrences(of: " ", with: "_") ?? "user\(id.prefix(4))")"
        self.email = email
        self.profileImageURL = nil
        self.bio = nil
        self.following = []
        self.followers = []
        self.createdAt = Date()
    }
}
