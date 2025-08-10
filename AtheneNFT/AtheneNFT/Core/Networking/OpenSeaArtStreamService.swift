import Foundation

// MARK: - OpenSea Art Stream Models

struct OSStreamNFT: Decodable, Identifiable, Hashable {
    let identifier: String
    let collection: String?
    let contract: String
    let tokenStandard: String?
    let name: String?
    let description: String?
    let imageURL: URL?
    let displayImageURL: URL?
    let displayAnimationURL: URL?
    let metadataURL: URL?
    let openseaURL: URL?
    let updatedAt: Date?
    let isDisabled: Bool?
    let isNSFW: Bool?

    var id: String { "\(contract.lowercased()):\(identifier)" }

    enum CodingKeys: String, CodingKey {
        case identifier
        case collection
        case contract
        case tokenStandard = "token_standard"
        case name
        case description
        case imageURL = "image_url"
        case displayImageURL = "display_image_url"
        case displayAnimationURL = "display_animation_url"
        case metadataURL = "metadata_url"
        case openseaURL = "opensea_url"
        case updatedAt = "updated_at"
        case isDisabled = "is_disabled"
        case isNSFW = "is_nsfw"
    }
}

private struct OSStreamResponse: Decodable {
    let nfts: [OSStreamNFT]
    let next: String?
}

// MARK: - Lightweight Streamer

/// Streams Art NFTs from OpenSea using a cursor-based endpoint.
/// You must provide an API key via the OPENSEA_API_KEY environment variable.
/// Optionally override the endpoint via OPENSEA_ART_STREAM_URL environment variable
/// to match the JSON shape shown in the user sample.
final class OpenSeaArtStreamService {
    private let session: URLSession
    private let apiKey: String?
    private let baseURL: URL
    private let useSeed: Bool

    init() {
        self.session = URLSession(configuration: .default)
        self.apiKey = ProcessInfo.processInfo.environment["OPENSEA_API_KEY"]
        if let override = ProcessInfo.processInfo.environment["OPENSEA_ART_STREAM_URL"],
           let url = URL(string: override) {
            self.baseURL = url
            let forceSeed = (ProcessInfo.processInfo.environment["OPENSEA_FORCE_SEED"] ?? "").lowercased() == "true"
            self.useSeed = forceSeed
        } else {
            // Default to OpenSea v2 search NFTs endpoint; requires API key.
            self.baseURL = URL(string: "https://api.opensea.io/api/v2/search/nfts")!
            // If no API key, use the embedded seed so UI still shows content.
            let forceSeed = (ProcessInfo.processInfo.environment["OPENSEA_FORCE_SEED"] ?? "").lowercased() == "true"
            self.useSeed = forceSeed || (self.apiKey ?? "").isEmpty
        }
    }

    func streamArtNFTs(chain: String = "ethereum") -> AsyncStream<OSStreamNFT> {
        AsyncStream { continuation in
            Task {
                var cursor: String? = nil
                var seen = Set<String>()
                // If no endpoint configured, yield from the embedded seed once
                if useSeed {
                    Self.yieldSeed(into: &seen, to: continuation)
                    continuation.finish(); return
                }
                do {
                    var didYieldAny = false
                    fetchLoop: while !Task.isCancelled {
                        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
                        var query: [URLQueryItem] = [
                            .init(name: "chain", value: chain),
                            .init(name: "category", value: "art"),
                            .init(name: "limit", value: "50"),
                            // Extra safety: some deployments expect a free-text query instead of category
                            .init(name: "q", value: "art")
                        ]
                        if let c = cursor { query.append(.init(name: "next", value: c)) }
                        components.queryItems = query

                        var request = URLRequest(url: components.url!)
                        if let apiKey { request.addValue(apiKey, forHTTPHeaderField: "x-api-key") }
                        request.addValue("application/json", forHTTPHeaderField: "accept")

                        let (data, response) = try await session.data(for: request)
                        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                            // If unauthorized or forbidden, fall back to seed once so UI renders.
                            if !didYieldAny && (http.statusCode == 401 || http.statusCode == 403) {
                                Self.yieldSeed(into: &seen, to: continuation)
                                didYieldAny = true
                            }
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            continue fetchLoop
                        }

                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        guard let page = try? decoder.decode(OSStreamResponse.self, from: data) else {
                            print("[OpenSeaArtStream] decode failed; falling back to seed once.")
                            if !didYieldAny { Self.yieldSeed(into: &seen, to: continuation); didYieldAny = true }
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            continue fetchLoop
                        }

                        if page.nfts.isEmpty && !didYieldAny {
                            print("[OpenSeaArtStream] 200 OK but empty list; yielding seed once.")
                            Self.yieldSeed(into: &seen, to: continuation)
                            didYieldAny = true
                        }
                        for nft in page.nfts {
                            if seen.insert(nft.id).inserted {
                                continuation.yield(nft)
                                didYieldAny = true
                            }
                        }
                        if let n = page.next, !n.isEmpty {
                            cursor = n
                        } else {
                            if !didYieldAny { // nothing yielded from first page → seed so UI isn't empty
                                Self.yieldSeed(into: &seen, to: continuation)
                                didYieldAny = true
                            }
                            // No more pages; short sleep then poll again
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            cursor = nil
                        }
                    }
                } catch {
                    if !Task.isCancelled {
                        // Show seed to avoid an empty UI on unexpected errors
                        Self.yieldSeed(into: &seen, to: continuation)
                    }
                }
                continuation.finish()
            }
        }
    }
}

// MARK: - Embedded seed (user-provided JSON) for art when no endpoint is configured
extension OpenSeaArtStreamService {
    static func yieldSeed(into seen: inout Set<String>, to continuation: AsyncStream<OSStreamNFT>.Continuation) {
        if let data = OpenSeaArtStreamService.seedJSON.data(using: .utf8) {
            let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
            if let page = try? decoder.decode(OSStreamResponse.self, from: data) {
                for nft in page.nfts { if seen.insert(nft.id).inserted { continuation.yield(nft) } }
            }
        }
    }
    // Note: This is a shortened seed of the user-provided payload; add/remove entries as desired.
    // It preserves the exact field names so decoding matches production.
    static let seedJSON: String = """
{
  "nfts": [
    {
      "identifier": "1",
      "collection": "nft-735358879",
      "contract": "0x0a4d6e644abe74269cd30be6d1cba8b4576541ee",
      "token_standard": "erc1155",
      "name": "MARCH INTO THE FUCKING LIGHT",
      "description": "",
      "image_url": "https://i2.seadn.io/ethereum/0x0a4d6e644abe74269cd30be6d1cba8b4576541ee/88c32092e4a867dbf8acb828c30b8d/1088c32092e4a867dbf8acb828c30b8d.gif",
      "display_image_url": "https://i2.seadn.io/ethereum/0x0a4d6e644abe74269cd30be6d1cba8b4576541ee/88c32092e4a867dbf8acb828c30b8d/1088c32092e4a867dbf8acb828c30b8d.gif",
      "display_animation_url": "https://raw2.seadn.io/ethereum/0x0a4d6e644abe74269cd30be6d1cba8b4576541ee/b20369c9228d0091c32b6e564188ae/2eb20369c9228d0091c32b6e564188ae.mp4",
      "metadata_url": "https://arweave.net/qftCX5l5kZSVmmFRrpDOga_6eAp0g9MI_2cC0VMGR3A/",
      "opensea_url": "https://opensea.io/assets/ethereum/0x0a4d6e644abe74269cd30be6d1cba8b4576541ee/1",
      "updated_at": "2025-08-11T04:42:00.788037",
      "is_disabled": false,
      "is_nsfw": false
    },
    {
      "identifier": "87",
      "collection": "leos1",
      "contract": "0x7f10e1f656bafbe92b5dcb2f11d95c43b36a1f11",
      "token_standard": "erc721",
      "name": "#LEO87",
      "description": "Leones en lugares.",
      "image_url": "https://i2.seadn.io/ethereum/0x7f10e1f656bafbe92b5dcb2f11d95c43b36a1f11/ff27cb897d4832c54ce8b3ea3f062a/20ff27cb897d4832c54ce8b3ea3f062a.png",
      "display_image_url": "https://i2.seadn.io/ethereum/0x7f10e1f656bafbe92b5dcb2f11d95c43b36a1f11/ff27cb897d4832c54ce8b3ea3f062a/20ff27cb897d4832c54ce8b3ea3f062a.png",
      "display_animation_url": null,
      "metadata_url": "ipfs://bafybeiaw45r7xcjewmjz7uq6hasqddx22keqveah3lgrkqwrpj53qplwbi/87.json",
      "opensea_url": "https://opensea.io/assets/ethereum/0x7f10e1f656bafbe92b5dcb2f11d95c43b36a1f11/87",
      "updated_at": "2025-08-11T04:42:00.787752",
      "is_disabled": false,
      "is_nsfw": false
    },
    {
      "identifier": "2",
      "collection": "cryptopunks-legendary-68941955",
      "contract": "0x5a1f6515a469629c6c7abab7ff3db9296184b796",
      "token_standard": "erc1155",
      "name": "CryptoPunk #7804",
      "description": "",
      "image_url": "https://i2.seadn.io/ethereum/0x5a1f6515a469629c6c7abab7ff3db9296184b796/da47e0dd481626186cfd961334317e/27da47e0dd481626186cfd961334317e.png",
      "display_image_url": "https://i2.seadn.io/ethereum/0x5a1f6515a469629c6c7abab7ff3db9296184b796/da47e0dd481626186cfd961334317e/27da47e0dd481626186cfd961334317e.png",
      "display_animation_url": null,
      "metadata_url": "ipfs://QmcAxqx31amXfgNwwiBTeBghjnkYRkEMFpfLHpz8qMaELS/2",
      "opensea_url": "https://opensea.io/assets/ethereum/0x5a1f6515a469629c6c7abab7ff3db9296184b796/2",
      "updated_at": "2025-08-11T04:42:00.787671",
      "is_disabled": false,
      "is_nsfw": false
    }
  ],
  "next": null
}
"""
}


