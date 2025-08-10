import Foundation

public enum ListingError: Error, LocalizedError {
  case notEnabled, notConfigured, backend(String)
  public var errorDescription: String? {
    switch self {
      case .notEnabled: return "Backend disabled."
      case .notConfigured: return "LISTING_BACKEND_URL not set."
      case .backend(let m): return m
    }
  }
}

public struct ListingBackendClient {
  public static var baseURL: URL? = {
    if let s = ProcessInfo.processInfo.environment["LISTING_BACKEND_URL"], !s.isEmpty { return URL(string: s) }
    return nil
  }()

  public struct CreateBody: Codable { public let chain, contract, tokenId, price, maker: String }
  public struct CreateResp: Codable { public let requestId: String; public let typedData: [String: AnyJSON] }
  public struct SubmitBody: Codable { public let requestId: String; public let signature: String }
  public struct SubmitResp: Codable { public let status: String; public let orderHash: String?; public let error: String? }

  public static func create(_ body: CreateBody) async throws -> CreateResp {
    #if BACKEND_ENABLED
    guard let url = baseURL?.appendingPathComponent("listings/create") else { throw ListingError.notConfigured }
    var req = URLRequest(url: url); req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try JSONEncoder().encode(body)
    let (data, resp) = try await URLSession.shared.data(for: req)
    guard (resp as? HTTPURLResponse)?.statusCode ?? 500 < 300 else {
      throw ListingError.backend(String(data: data, encoding: .utf8) ?? "HTTP error")
    }
    return try JSONDecoder().decode(CreateResp.self, from: data)
    #else
    throw ListingError.notEnabled
    #endif
  }

  public static func submit(_ body: SubmitBody) async throws -> SubmitResp {
    #if BACKEND_ENABLED
    guard let url = baseURL?.appendingPathComponent("listings/submit") else { throw ListingError.notConfigured }
    var req = URLRequest(url: url); req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try JSONEncoder().encode(body)
    let (data, resp) = try await URLSession.shared.data(for: req)
    guard (resp as? HTTPURLResponse)?.statusCode ?? 500 < 300 else {
      throw ListingError.backend(String(data: data, encoding: .utf8) ?? "HTTP error")
    }
    return try JSONDecoder().decode(SubmitResp.self, from: data)
    #else
    throw ListingError.notEnabled
    #endif
  }
}


