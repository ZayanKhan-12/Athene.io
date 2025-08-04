import Foundation
import Web3

class MetaMaskService {
    static let shared = MetaMaskService()
    
    private let userDefaults = UserDefaults.standard
    private let keychainService = KeychainService.shared
    
    private let accountKey = "metamask_account"
    private let signatureKey = "metamask_signature"
    
    struct MetaMaskAccount {
        let address: String
        let signature: String
        let timestamp: Date
    }
    
    func saveAccount(_ address: String, signature: String) {
        let account = MetaMaskAccount(
            address: address,
            signature: signature,
            timestamp: Date()
        )
        
        // Save address to UserDefaults
        userDefaults.set(address, forKey: accountKey)
        
        // Save signature securely in Keychain
        try? keychainService.save(signature, for: signatureKey)
    }
    
    func getStoredAccount() -> MetaMaskAccount? {
        guard let address = userDefaults.string(forKey: accountKey),
              let signature = try? keychainService.get(for: signatureKey) else {
            return nil
        }
        
        return MetaMaskAccount(
            address: address,
            signature: signature,
            timestamp: Date()
        )
    }
    
    func clearStoredAccount() {
        userDefaults.removeObject(forKey: accountKey)
        try? keychainService.delete(for: signatureKey)
    }
}
