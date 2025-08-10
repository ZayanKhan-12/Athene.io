import Foundation
import Combine

// Lightweight OpenSea Stream API client using URLSessionWebSocketTask
// Subscribes to global or collection-specific events and publishes them to SwiftUI

@MainActor
final class OpenSeaStreamService: ObservableObject {
    static let shared = OpenSeaStreamService()
    private let eventsSubject = PassthroughSubject<FeedStreamEvent, Never>()
    public var eventsPublisher: AnyPublisher<FeedStreamEvent, Never> { eventsSubject.eraseToAnyPublisher() }

    struct StreamEventItem: Identifiable, Hashable {
        let id = UUID().uuidString
        let type: String
        let title: String
        let subtitle: String
        let imageURL: String?
        let assetURL: URL?
        let timestamp: Date = Date()
    }

    @Published private(set) var events: [StreamEventItem] = []

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    private let streamURL = URL(string: "wss://stream.openseabeta.com/socket")!
    private var apiKey: String {
        ProcessInfo.processInfo.environment["OPENSEA_API_KEY"] as String?
        ?? (Bundle.main.object(forInfoDictionaryKey: "OPENSEA_API_KEY") as? String)
        ?? ""
    }

    func connect(collectionSlug: String? = nil) {
        disconnect()
        var url = streamURL
        if let slug = collectionSlug, !slug.isEmpty {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            comps.queryItems = [URLQueryItem(name: "collection_slug", value: slug)]
            url = comps.url ?? url
        }
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        let task = session.webSocketTask(with: request)
        webSocketTask = task
        task.resume()
        receive()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }

    private func receive() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .failure:
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                        Task { @MainActor in self?.receive() }
                    }
                case .success(let message):
                    switch message {
                    case .data(let data):
                        self.consume(data: data)
                    case .string(let text):
                        if let data = text.data(using: .utf8) { self.consume(data: data) }
                    @unknown default: break
                    }
                    self.receive()
                }
            }
        }
    }

    private func consume(data: Data) {
        // The Stream payload can vary; we extract basic fields defensively
        struct P: Decodable {
            let type: String?
            let payload: Payload?
            struct Payload: Decodable {
                let item: Item?
                let collection: Collection?
                let price: String?
                let maker: String?
                let taker: String?
                struct Item: Decodable {
                    let metadata: Metadata?
                    let chain: String?
                    let contract: String?
                    let token_id: String?
                }
                struct Metadata: Decodable { let name: String?; let image_url: String? }
                struct Collection: Decodable { let slug: String? }
            }
        }
        guard let parsed = try? JSONDecoder().decode(P.self, from: data), let type = parsed.type else { return }
        let name = parsed.payload?.item?.metadata?.name ?? parsed.payload?.collection?.slug ?? "NFT"
        let image = parsed.payload?.item?.metadata?.image_url
        let chain = parsed.payload?.item?.chain ?? "ethereum"
        let contract = parsed.payload?.item?.contract ?? ""
        let tokenId = parsed.payload?.item?.token_id ?? ""
        let title = name
        var subtitle = type.replacingOccurrences(of: "_", with: " ").capitalized
        if let price = parsed.payload?.price, !price.isEmpty {
            subtitle += " • \(price)"
        }
        let assetURL: URL? = (contract.isEmpty || tokenId.isEmpty) ? nil : URL(string: "https://opensea.io/assets/\(chain)/\(contract)/\(tokenId)")
        let item = StreamEventItem(type: type, title: title, subtitle: subtitle, imageURL: image, assetURL: assetURL)
        events.insert(item, at: 0)
        if events.count > 200 { events.removeLast(events.count - 200) }
        if let slug = parsed.payload?.collection?.slug,
           let contract = parsed.payload?.item?.contract,
           let tokenId = parsed.payload?.item?.token_id {
            let ts = Date()
            let evtType: FeedEventType = mapType(type)
            let owner = parsed.payload?.maker ?? parsed.payload?.taker
            let priceWei = parsed.payload?.price
            let mediaURL = parsed.payload?.item?.metadata?.image_url.flatMap { URL(string: $0) }
            let evt = FeedStreamEvent(
                id: "\(contract.lowercased())#\(tokenId)#\(Int(ts.timeIntervalSince1970))",
                ts: ts,
                type: evtType,
                collectionSlug: slug,
                contract: contract.lowercased(),
                tokenId: tokenId,
                priceWei: priceWei,
                owner: owner?.lowercased(),
                mediaURL: mediaURL
            )
            eventsSubject.send(evt)
        }
    }

    private func mapType(_ raw: String) -> FeedEventType {
        let k = raw.lowercased()
        if k.contains("list") { return .listed }
        if k.contains("offer") || k.contains("bid") { return .offer }
        if k.contains("sale") || k.contains("sell") || k.contains("match") { return .sold }
        if k.contains("transfer") { return .transfer }
        return .metadata
    }

    private func weiToEth(_ s: String) -> Double? {
        guard let v = Double(s) else { return nil }
        return v / 1e18
    }
}


