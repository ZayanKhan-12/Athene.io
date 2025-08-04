import Foundation
import Web3

class UserService {
    static let shared = UserService()
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    func authenticate(walletAddress: String, signature: String, nonce: String) async throws -> AuthResponse {
        let endpoint = "\(APIConfig.baseURL)/auth/metamask"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let authRequest = AuthRequest(
            walletAddress: walletAddress,
            signature: signature,
            nonce: nonce
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = APIConfig.headers
        request.httpBody = try encoder.encode(authRequest)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let authResponse = try decoder.decode(AuthResponse.self, from: data)
            KeychainService.shared.saveAuthToken(authResponse.token)
            return authResponse
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.userNotFound
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func getUser(withWalletAddress address: String) async throws -> User? {
        let endpoint = "\(APIConfig.baseURL)/users/wallet/\(address)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = APIConfig.headers
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(User.self, from: data)
        case 404:
            return nil
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func createUser(walletAddress: String, username: String) async throws -> User {
        let endpoint = "\(APIConfig.baseURL)/users"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let newUser = CreateUserRequest(
            walletAddress: walletAddress,
            username: username
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = APIConfig.headers
        request.httpBody = try encoder.encode(newUser)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(User.self, from: data)
        case 400:
            let error = try decoder.decode(APIError.self, from: data)
            throw NetworkError.validationError(message: error.message)
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func updateUser(_ user: User) async throws -> User {
        let endpoint = "\(APIConfig.baseURL)/users/\(user.id)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = APIConfig.headers
        request.httpBody = try encoder.encode(user)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(User.self, from: data)
        case 400:
            let error = try decoder.decode(APIError.self, from: data)
            throw NetworkError.validationError(message: error.message)
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.userNotFound
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}

// Models
struct AuthRequest: Codable {
    let walletAddress: String
    let signature: String
    let nonce: String
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct CreateUserRequest: Codable {
    let walletAddress: String
    let username: String
}

struct APIError: Codable {
    let message: String
    let code: String?
}

// Error handling
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case userNotFound
    case validationError(message: String)
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized access"
        case .userNotFound:
            return "User not found"
        case .validationError(let message):
            return message
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        }
    }
}
