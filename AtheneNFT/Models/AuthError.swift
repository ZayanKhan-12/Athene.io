import Foundation

enum AuthError: LocalizedError {
    case metamaskNotInstalled
    case wrongNetwork(expected: String)
    case noWalletAddress
    case signatureRequired
    case invalidStoredAccount
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .metamaskNotInstalled:
            return "MetaMask is not installed. Please install MetaMask to continue."
        case .wrongNetwork(let expected):
            return "Please switch to \(expected) network in MetaMask."
        case .noWalletAddress:
            return "No wallet address found. Please connect your MetaMask wallet."
        case .signatureRequired:
            return "Signature is required to verify your wallet ownership."
        case .invalidStoredAccount:
            return "Stored account is no longer valid. Please reconnect your wallet."
        case .userNotFound:
            return "User profile not found. Please create a new profile."
        }
    }
}
