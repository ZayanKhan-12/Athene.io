import Foundation
import Web3

class Web3Service {
    static let shared = Web3Service()
    private var web3: Web3?
    
    private init() {
        setupWeb3()
    }
    
    private func setupWeb3() {
        let config = APIConfig.web3Config
        guard let provider = Web3.InfuraProvider(
            url: URL(string: config.rpcURL)!
        ) else {
            print("Failed to initialize Web3")
            return
        }
        self.web3 = Web3(provider: provider)
    }
    
    // Test connection and get current block number
    func testConnection() async throws -> String {
        guard let web3 = web3 else {
            throw Web3Error.notInitialized
        }
        
        let blockNumber = try await web3.eth.blockNumber()
        return "Connected to Ethereum network. Current block: \(blockNumber)"
    }
    
    // Get ETH balance for address
    func getBalance(for address: String) async throws -> String {
        guard let web3 = web3 else {
            throw Web3Error.notInitialized
        }
        
        guard let ethAddress = EthereumAddress(address) else {
            throw Web3Error.invalidAddress
        }
        
        let balance = try await web3.eth.getBalance(address: ethAddress)
        let ethBalance = web3.utils.fromWei(balance, unit: .ether)
        return ethBalance
    }
    
    func getWeb3() -> Web3? {
        return web3
    }
    
    func signMessage(_ message: String, from address: EthereumAddress) async throws -> String {
        guard let web3 = web3 else {
            throw Web3Error.notInitialized
        }
        
        return try await web3.eth.personal.sign(
            message: message,
            account: address
        )
    }
    
    func verifySignature(
        message: String,
        signature: String,
        address: EthereumAddress
    ) async throws -> Bool {
        guard let web3 = web3 else {
            throw Web3Error.notInitialized
        }
        
        return try await web3.eth.personal.ecrecover(
            message: message,
            signature: signature
        ) == address
    }
    
    func getCurrentNetwork() async throws -> EthereumNetwork {
        guard let web3 = web3 else {
            throw Web3Error.notInitialized
        }
        
        let networkId = try await web3.eth.net.version()
        switch networkId {
        case "1":
            return .mainnet
        case "4":
            return .rinkeby
        default:
            throw Web3Error.unsupportedNetwork
        }
    }
}

enum Web3Error: LocalizedError {
    case notInitialized
    case unsupportedNetwork
    case signatureError
    case invalidAddress
    
    var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Web3 is not initialized"
        case .unsupportedNetwork:
            return "Unsupported Ethereum network"
        case .signatureError:
            return "Failed to sign message"
        case .invalidAddress:
            return "Invalid Ethereum address"
        }
    }
}
