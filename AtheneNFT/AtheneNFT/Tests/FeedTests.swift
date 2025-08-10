import XCTest
@testable import AtheneNFT

final class FeedTests: XCTestCase {
    func testScoringTimeDecay() {
        let now = Date()
        let recent = FeedItem(id: "a", ts: now, type: .listed, collectionSlug: "c", contract: "k", tokenId: "1", priceEth: nil, owner: nil, mediaURL: nil)
        let old = FeedItem(id: "b", ts: now.addingTimeInterval(-6*3600), type: .listed, collectionSlug: "c", contract: "k", tokenId: "2", priceEth: nil, owner: nil, mediaURL: nil)
        let s = FeedScorer()
        let ctx = FeedScorer.Ctx(affinity: { _ in 0 }, engagementPred: { _ in 0 }, priceMomentum: { _ in 0 }, diversityPenalty: { _ in 0 })
        XCTAssertGreaterThan(s.score(item: recent, ctx: ctx), s.score(item: old, ctx: ctx))
    }

    func testDiversityGuard() async {
        let store = FeedStore(capacity: 10)
        let ctx = FeedScorer.Ctx(affinity: { _ in 0 }, engagementPred: { _ in 0 }, priceMomentum: { _ in 0 }, diversityPenalty: { _ in 0 })
        let s = FeedScorer()
        for i in 0..<10 {
            let it = FeedItem(id: "x#\(i)", ts: Date(), type: .listed, collectionSlug: i < 5 ? "slugA" : "slugB", contract: "k", tokenId: "\(i)", priceEth: nil, owner: nil, mediaURL: nil)
            store.upsert(it, score: s.score(item: it, ctx: ctx))
        }
        let top20 = Array(store.items.prefix(20))
        let countA = top20.filter { $0.collectionSlug == "slugA" }.count
        XCTAssertLessThanOrEqual(countA, 2)
    }

    func testEventsDecode() throws {
        let json = """
        {"events":[{"event_type":"listing","collection_slug":"c","contract_address":"0xabc","token_id":"1","created_date":"2024-01-02T03:04:05Z","price":"1000000000000000000"}],"next":null}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(OSEventsResponse.self, from: json)
        XCTAssertEqual(decoded.events.count, 1)
        XCTAssertNotNil(decoded.events.first?.toFeedItem())
    }
}


