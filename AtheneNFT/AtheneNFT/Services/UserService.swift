import Foundation

class UserService {
    static let shared = UserService()
    private let defaults = UserDefaults.standard
    private let userKey = "com.athene.currentUser"
    
    private init() {}
    
    func createUser(walletAddress: String) async throws -> User {
        // Check if user already exists
        if let existingUser = try? await getUserByWallet(walletAddress: walletAddress) {
            return existingUser
        }
        
        // Create new user
        let newUser = User(walletAddress: walletAddress)
        
        // In a real implementation, this would make an API call to create the user in your backend
        // For now, we'll store it locally
        try saveUser(newUser)
        
        return newUser
    }
    
    func getUserByWallet(walletAddress: String) async throws -> User? {
        // In a real implementation, this would make an API call to fetch the user
        // For now, we'll check local storage
        if let userData = defaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData),
           user.walletAddress.lowercased() == walletAddress.lowercased() {
            return user
        }
        return nil
    }
    
    private func saveUser(_ user: User) throws {
        let encoder = JSONEncoder()
        let userData = try encoder.encode(user)
        defaults.set(userData, forKey: userKey)
    }
    
    func getCurrentUser() -> User? {
        guard let userData = defaults.data(forKey: userKey) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: userData)
    }
    
    func logout() {
        defaults.removeObject(forKey: userKey)
    }
    
    func updateUser(_ user: User) throws {
        try saveUser(user)
    }
}
