import Foundation

enum Environment {
    case development
    case staging
    case production
    
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        // You can customize this based on your build configuration
        return .production
        #endif
    }
}

enum APIConfig {
    static var baseURL: String {
        switch Environment.current {
        case .development:
            return "http://localhost:3000/api/v1"
        case .staging:
            return "https://staging-api.athene.io/v1"
        case .production:
            return "https://api.athene.io/v1"
        }
    }
    
    static var web3Config: Web3Config {
        switch Environment.current {
        case .development:
            return Web3Config(
                infuraProjectId: "249221cc67f5466698376496f0f20b6b",
                network: .mainnet // Using mainnet for development since Rinkeby is deprecated
            )
        case .staging:
            return Web3Config(
                infuraProjectId: "249221cc67f5466698376496f0f20b6b",
                network: .mainnet
            )
        case .production:
            return Web3Config(
                infuraProjectId: "249221cc67f5466698376496f0f20b6b",
                network: .mainnet
            )
        }
    }
    
    static var headers: [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Client-Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            "X-Platform": "iOS"
        ]
        
        if let authToken = KeychainService.shared.getAuthToken() {
            headers["Authorization"] = "Bearer \(authToken)"
        }
        
        return headers
    }
}

struct Web3Config {
    let infuraProjectId: String
    let network: EthereumNetwork
    
    var rpcURL: String {
        switch network {
        case .mainnet:
            return "https://mainnet.infura.io/v3/\(infuraProjectId)"
        case .rinkeby:
            return "https://rinkeby.infura.io/v3/\(infuraProjectId)"
        }
    }
}

enum EthereumNetwork {
    case mainnet
    case rinkeby
}
