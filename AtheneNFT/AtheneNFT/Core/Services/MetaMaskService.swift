import Foundation
#if os(iOS)
import UIKit
#endif

class MetaMaskService {
    static let shared = MetaMaskService()
    private let apiKey = "249221cc67f5466698376496f0f20b6b" // Web3Auth API Key
    private var currentAccount: String?
    private let web3AuthNetwork = "sapphire_devnet" // Use mainnet for production
    
    // Properties for async/await pattern with callbacks
    private var connectContinuation: CheckedContinuation<String, Error>?
    private var signContinuation: CheckedContinuation<String, Error>?
    
    private init() {
        // Register for MetaMask connection notifications
        NotificationCenter.default.addObserver(
            forName: Notification.Name("MetaMaskConnected"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let address = notification.userInfo?["address"] as? String,
                  let continuation = self.connectContinuation else {
                return
            }
            
            self.currentAccount = address
            self.connectContinuation = nil
            continuation.resume(returning: address)
        }
        
        // Register for MetaMask signature notifications
        NotificationCenter.default.addObserver(
            forName: Notification.Name("MetaMaskSignatureReceived"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let signature = notification.userInfo?["signature"] as? String,
                  let continuation = self.signContinuation else {
                return
            }
            
            self.signContinuation = nil
            continuation.resume(returning: signature)
        }
    }
    
    func connect() async throws -> String {
        #if os(iOS)
        // Initialize MetaMask connection using deep linking
        let deepLink = "https://metamask.app.link/dapp/athene.io?apiKey=\(apiKey)"
        
        // Open MetaMask if installed or App Store if not
        guard let url = URL(string: deepLink) else {
            throw MetaMaskError.connectionFailed
        }
        
        // Open MetaMask in main thread
        await MainActor.run {
            UIApplication.shared.open(url)
        }
        #endif
        
        // Return a value using continuation pattern or simulate for other platforms
        return try await withCheckedThrowingContinuation { continuation in
            self.connectContinuation = continuation
            
            // For demo/testing purposes on non-iOS platforms, we'll simulate a callback after a delay
            #if !os(iOS)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                let sampleAddress = "0x742d35Cc6634C0532925a3b844Bc454e4438f44e"
                self.currentAccount = sampleAddress
                continuation.resume(returning: sampleAddress)
            }
            #endif
        }
    }
    
    func isConnected() -> Bool {
        return currentAccount != nil
    }
    
    func getAccount() -> String? {
        return currentAccount
    }
    
    func disconnect() {
        currentAccount = nil
    }
    
    func sign(message: String) async throws -> String {
        guard let account = currentAccount else {
            throw MetaMaskError.notConnected
        }
        
        #if os(iOS)
        // In a real implementation, this would send the message to MetaMask for signing via deep linking
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? message
        let signUrl = "https://metamask.app.link/dapp/athene.io/sign?message=\(encodedMessage)&address=\(account)"
        
        guard let url = URL(string: signUrl) else {
            throw MetaMaskError.signatureFailure
        }
        
        // Open MetaMask in main thread
        await MainActor.run {
            UIApplication.shared.open(url)
        }
        #endif
        
        // Return a value using continuation pattern or simulate for other platforms
        return try await withCheckedThrowingContinuation { continuation in
            self.signContinuation = continuation
            
            // For demo/testing purposes on non-iOS platforms or when we don't get a callback
            #if !os(iOS)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let mockSignature = "0x742d35Cc6634C0532925a3b844Bc454e4438f44e1b94643700054a45dd22842f2a3985704e87536ad35768f4c8b0fdb651be7b9181e1ce121c8c36c3f7c6e39a1c"
                continuation.resume(returning: mockSignature)
            }
            #endif
        }
    }
    
    func getBalance() async throws -> String {
        guard let _ = currentAccount else {
            throw MetaMaskError.notConnected
        }
        
        // This would fetch the balance from the Ethereum node
        // For demo purposes, we'll return a mock balance
        return "1.2 ETH"
    }
}

enum MetaMaskError: Error {
    case notConnected
    case signatureFailure
    case invalidAddress
    case connectionFailed
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .notConnected:
            return "Not connected to MetaMask. Please connect your wallet first."
        case .signatureFailure:
            return "Failed to sign message with MetaMask."
        case .invalidAddress:
            return "Invalid Ethereum address format."
        case .connectionFailed:
            return "Failed to connect to MetaMask. Please try again."
        case .networkError:
            return "Network error occurred while connecting to Ethereum network."
        }
    }
}
