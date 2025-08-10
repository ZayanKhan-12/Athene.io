import Foundation
import Combine

@MainActor
final class FeedService: ObservableObject {
    @Published private(set) var items: [FeedItem] = []

    private let stream: OpenSeaStreamService
    private let nft: NFTService
    private let follows: FollowService
    private let store: FeedStore
    private let scorer = FeedScorer()
    private let api: OpenSeaAPI
    private var bag = Set<AnyCancellable>()

    // Caches
    private var floors: [String: CollectionFloorSnapshot] = [:]
    private var engagement: [String: Double] = [:] // id -> 0..1

    init(stream: OpenSeaStreamService, nft: NFTService, follows: FollowService, apiKey: String, capacity: Int = 300) {
        self.stream = stream
        self.nft = nft
        self.follows = follows
        self.api = OpenSeaAPI(apiKey: apiKey)
        self.store = FeedStore(capacity: capacity)
    }

    func start() async {
        bindStream()
        await refreshFloors()
        let slugs = follows.followedCollections()
        await backfill(slugs: slugs)
        self.items = store.items
        scheduleFloorRefresh()
    }

    private func bindStream() {
        stream.eventsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] evt in
                Task { @MainActor in self?.onStream(evt) }
            }
            .store(in: &bag)
    }

    private func onStream(_ e: FeedStreamEvent) {
        let item = mapToFeedItem(e)
        let score = scorer.score(item: item, ctx: makeCtx())
        store.upsert(item, score: score)
        items = store.items
    }

    private func mapToFeedItem(_ e: FeedStreamEvent) -> FeedItem {
        let id = "\(e.contract)#\(e.tokenId)#\(Int(e.ts.timeIntervalSince1970))"
        return FeedItem(id: id, ts: e.ts, type: e.type, collectionSlug: e.collectionSlug, contract: e.contract, tokenId: e.tokenId, priceEth: e.priceEth, owner: e.owner, mediaURL: e.mediaURL)
    }

    func backfill(slugs: [String]) async {
        let now = Date(); let start = now.addingTimeInterval(-6*3600)
        let iso = ISO8601DateFormatter()
        for slug in slugs {
            var cursor: String? = nil
            var pages = 0
            repeat {
                var q: [URLQueryItem] = [
                    .init(name: "collection_slug", value: slug),
                    .init(name: "occurred_after", value: iso.string(from: start)),
                    .init(name: "occurred_before", value: iso.string(from: now)),
                    .init(name: "limit", value: "50")
                ]
                if let c = cursor { q.append(.init(name: "next", value: c)) }
                guard let resp = try? await api.getEvents(query: q) else { break }
                let decoded = try? JSONDecoder().decode(OSEventsResponse.self, from: resp)
                decoded?.events.forEach { ev in
                    guard let mapped = ev.toFeedItem() else { return }
                    let score = scorer.score(item: mapped, ctx: makeCtx())
                    store.upsert(mapped, score: score)
                }
                cursor = decoded?.next
                pages += 1
            } while cursor != nil && pages < 3
        }
        items = store.items
    }

    private func hydrate(contract: String, tokenId: String, slug: String) async -> (Double?, URL?) {
        let listings = try? await api.getListings(chain: "ethereum", protocolName: "seaport", query: [
            .init(name: "asset_contract_address", value: contract),
            .init(name: "token_ids", value: tokenId),
            .init(name: "limit", value: "1")
        ])
        let offers = try? await api.getOffers(chain: "ethereum", protocolName: "seaport", query: [
            .init(name: "asset_contract_address", value: contract),
            .init(name: "token_ids", value: tokenId),
            .init(name: "limit", value: "1")
        ])
        let l = listings.flatMap { try? JSONDecoder().decode(OSListingsResponse.self, from: $0) }
        let o = offers.flatMap { try? JSONDecoder().decode(OSOffersResponse.self, from: $0) }
        let priceEth = l?.bestPriceEth() ?? o?.bestBidEth()
        return (priceEth, nil)
    }

    private func scheduleFloorRefresh() {
        Task { [weak self] in
            guard let self else { return }
            while true {
                try? await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000)
                await self.refreshFloors()
            }
        }
    }

    private func refreshFloors() async {
        let slugs = follows.followedCollections()
        await withTaskGroup(of: (String, CollectionFloorSnapshot?).self) { group in
            for slug in slugs {
                group.addTask {
                    let data = try? await self.api.getCollection(slug: slug)
                    let decoded = data.flatMap { try? JSONDecoder().decode(OSCollectionResponse.self, from: $0) }
                    let snap = decoded.flatMap { $0.toSnapshot() }
                    return (slug, snap)
                }
            }
            for await (slug, snap) in group { if let snap { floors[slug] = snap } }
        }
    }

    private func makeCtx() -> FeedScorer.Ctx {
        .init(
            affinity: { [weak self] item in
                guard let self else { return 0 }
                var v = 0.0
                if self.follows.followsOwner(item.owner ?? "") { v += 1.0 }
                if self.follows.followsCollection(item.collectionSlug) { v += 0.6 }
                if self.follows.friendOfFollow(item.owner ?? "") { v += 0.2 }
                return v
            },
            engagementPred: { [weak self] item in self?.engagement[item.id] ?? 0 },
            priceMomentum: { [weak self] slug in
                guard let f = self?.floors[slug]?.floorEth else { return 0 }
                // Placeholder momentum; replace with delta vs prior snapshot
                return f.isFinite ? 0.1 : 0
            },
            diversityPenalty: { [weak self] item in
                guard let self else { return 0 }
                let top = Array(self.store.items.prefix(10))
                let cnt = top.filter { $0.collectionSlug == item.collectionSlug }.count
                return cnt >= 2 ? 1.0 : 0.0
            }
        )
    }
}


