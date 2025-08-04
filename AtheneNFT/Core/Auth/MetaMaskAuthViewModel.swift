import SwiftUI
import Web3
import Combine

@MainActor
class MetaMaskAuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    @Published var showCreateProfile = false
    
    private let web3Service = Web3Service.shared
    private let userService = UserService.shared
    private let metamaskService = MetaMaskService.shared
    
    func loginWithStoredAccount(_ account: MetaMaskService.MetaMaskAccount) async throws {
        isLoading = true
        error = nil
        
        do {
            // Verify the stored account is still valid
            guard let web3 = web3Service.getWeb3() else {
                throw Web3Error.notInitialized
            }
            
            let accounts = try await web3.eth.getAccounts()
            guard accounts.contains(account.address.lowercased()) else {
                metamaskService.clearStoredAccount()
                throw AuthError.invalidStoredAccount
            }
            
            // Load user profile
            if let user = try? await userService.getUserProfile(address: account.address) {
                currentUser = user
                isAuthenticated = true
            } else {
                showCreateProfile = true
            }
        } catch {
            self.error = error.localizedDescription
            throw error
        } finally {
            isLoading = false
        }
    }
    
    func connectWallet() async throws {
        isLoading = true
        error = nil
        
        do {
            // Check if MetaMask is installed
            guard let metamaskUrl = URL(string: "metamask://") else {
                throw AuthError.metamaskNotInstalled
            }
            
            guard let web3 = web3Service.getWeb3() else {
                throw Web3Error.notInitialized
            }
            
            // Verify network
            let network = try await web3Service.getCurrentNetwork()
            guard network == Environment.current.ethereumNetwork else {
                throw AuthError.wrongNetwork(expected: Environment.current.ethereumNetwork)
            }
            
            // Request wallet connection
            let accounts = try await web3.eth.getAccounts()
            guard let address = accounts.first else {
                throw AuthError.noWalletAddress
            }
            
            // Generate and sign authentication message
            let nonce = UUID().uuidString
            let message = """
            Welcome to Athene!
            
            Please sign this message to verify your wallet ownership.
            
            Nonce: \(nonce)
            Timestamp: \(Date().ISO8601Format())
            """
            
            let signature = try await web3Service.signMessage(message, from: address)
            
            // Authenticate with backend
            let authResponse = try await userService.authenticate(
                walletAddress: address.hex,
                signature: signature,
                nonce: nonce
            )
            
            self.currentUser = authResponse.user
            self.isAuthenticated = true
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func createProfile(username: String, walletAddress: String) async {
        isLoading = true
        error = nil
        
        do {
            let user = try await userService.createUser(
                walletAddress: walletAddress,
                username: username
            )
            self.currentUser = user
            self.isAuthenticated = true
            self.showCreateProfile = false
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    func disconnect() {
        currentUser = nil
        isAuthenticated = false
        showCreateProfile = false
        KeychainService.shared.deleteAuthToken()
    }
    
    func testConnection() async {
        isLoading = true
        error = nil
        
        do {
            let status = try await web3Service.testConnection()
            // Show success message temporarily
            self.error = "✅ " + status
            
            // Clear success message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if self.error?.starts(with: "✅") == true {
                    self.error = nil
                }
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        if let authError = error as? AuthError {
            self.error = authError.localizedDescription
        } else if let networkError = error as? NetworkError {
            self.error = networkError.localizedDescription
        } else if let web3Error = error as? Web3Error {
            self.error = web3Error.localizedDescription
        } else {
            self.error = error.localizedDescription
        }
    }
}

enum AuthError: LocalizedError {
    case metamaskNotInstalled
    case wrongNetwork(expected: EthereumNetwork)
    case noWalletAddress
    case signatureVerificationFailed
    
    var errorDescription: String? {
        switch self {
        case .metamaskNotInstalled:
            return "MetaMask is not installed. Please install MetaMask to continue."
        case .wrongNetwork(let expected):
            return "Please switch to the \(expected) network in MetaMask."
        case .noWalletAddress:
            return "No wallet address found. Please connect your wallet in MetaMask."
        case .signatureVerificationFailed:
            return "Failed to verify signature. Please try again."
        }
    }
}
