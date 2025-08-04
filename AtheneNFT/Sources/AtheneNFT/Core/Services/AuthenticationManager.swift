import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    private let metamask = MetaMaskService.shared
    private let userService = UserService.shared
    
    @Published var currentUser: User?
    @Published var isAuthenticating = false
    @Published var error: Error?
    
    init() {
        currentUser = userService.getCurrentUser()
    }
    
    func loginWithMetaMask() async {
        do {
            isAuthenticating = true
            error = nil
            
            // Connect to MetaMask
            let walletAddress = try await metamask.connect()
            
            // Create or get user
            let user = try await userService.createUser(walletAddress: walletAddress)
            
            // Sign message to verify ownership
            let message = "Welcome to Athene! Sign this message to verify your wallet ownership.\nNonce: \(UUID().uuidString)"
            _ = try await metamask.sign(message: message)
            
            // Set current user
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticating = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isAuthenticating = false
            }
        }
    }
    
    func logout() {
        metamask.disconnect()
        userService.logout()
        currentUser = nil
    }
}

// MARK: - Error Types
enum AuthenticationError: LocalizedError {
    case signatureVerificationFailed
    case userCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .signatureVerificationFailed:
            return "Failed to verify wallet ownership"
        case .userCreationFailed:
            return "Failed to create user account"
        }
    }
}
