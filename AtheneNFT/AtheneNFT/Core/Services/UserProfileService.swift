import Foundation
import SwiftUI

// Lightweight OpenSea user profile fetcher with in-memory caching
@MainActor
final class UserProfileService: ObservableObject {
    static let shared = UserProfileService()

    struct Profile: Hashable {
        let address: String
        let username: String?
        let displayName: String?
        let profileImageURL: String?
    }

    private struct CacheEntry {
        let profile: Profile
        let expiry: Date
    }

    private var cache: [String: CacheEntry] = [:] // key: lowercased address
    private let session: URLSession
    private let baseURL = URL(string: "https://api.opensea.io")!
    private let cacheTTL: TimeInterval = 60 * 10 // 10 minutes

    private let apiKey: String = {
        if let env = ProcessInfo.processInfo.environment["OPENSEA_API_KEY"], !env.isEmpty {
            return env
        }
        if let fromPlist = Bundle.main.object(forInfoDictionaryKey: "OPENSEA_API_KEY") as? String, !fromPlist.isEmpty {
            return fromPlist
        }
        return "4ec329fc4a3141d7bb2c6a1e1875b7ef"
    }()

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProfile(address raw: String) async -> Profile? {
        let address = raw.lowercased()
        if let cached = cache[address], cached.expiry > Date() {
            return cached.profile
        }
        // Try v2 accounts endpoint first, then v1
        if let p2 = await fetchV2(address: address) {
            cache[address] = CacheEntry(profile: p2, expiry: Date().addingTimeInterval(cacheTTL))
            return p2
        }
        if let p1 = await fetchV1(address: address) {
            cache[address] = CacheEntry(profile: p1, expiry: Date().addingTimeInterval(cacheTTL))
            return p1
        }
        return nil
    }

    private func fetchV2(address: String) async -> Profile? {
        let url = baseURL.appendingPathComponent("/api/v2/accounts/\(address)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return nil }
            struct V2Response: Decodable {
                let account: V2Account?
                struct V2Account: Decodable {
                    let address: String?
                    let username: String?
                    let display_name: String?
                    let profile_image_url: String?
                }
            }
            // Some docs show direct object; support both
            if let asObj = try? JSONDecoder().decode(V2Response.V2Account.self, from: data) {
                return Profile(address: address, username: asObj.username, displayName: asObj.display_name, profileImageURL: asObj.profile_image_url)
            }
            if let wrapper = try? JSONDecoder().decode(V2Response.self, from: data), let acct = wrapper.account {
                return Profile(address: address, username: acct.username, displayName: acct.display_name, profileImageURL: acct.profile_image_url)
            }
            return nil
        } catch {
            return nil
        }
    }

    private func fetchV1(address: String) async -> Profile? {
        let url = baseURL.appendingPathComponent("/api/v1/user/\(address)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return nil }
            struct V1User: Decodable { let username: String?; let account: V1Account?; let profile_img_url: String? }
            struct V1Account: Decodable { let address: String? }
            if let u = try? JSONDecoder().decode(V1User.self, from: data) {
                return Profile(address: u.account?.address?.lowercased() ?? address, username: u.username, displayName: u.username, profileImageURL: u.profile_img_url)
            }
            return nil
        } catch {
            return nil
        }
    }
}


