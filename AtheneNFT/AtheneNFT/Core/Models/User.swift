import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: String
    let walletAddress: String
    var username: String?
    var email: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, walletAddress: String, username: String? = nil, email: String? = nil) {
        self.id = id
        self.walletAddress = walletAddress
        self.username = username
        self.email = email
        self.createdAt = Date()
    }
}
