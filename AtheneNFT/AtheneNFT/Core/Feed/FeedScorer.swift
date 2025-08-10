import Foundation

struct FeedScorer {
    struct Ctx {
        let affinity: (FeedItem) -> Double
        let engagementPred: (FeedItem) -> Double
        let priceMomentum: (String) -> Double
        let diversityPenalty: (FeedItem) -> Double
    }

    func score(item: FeedItem, ctx: Ctx) -> Double {
        let ageMin = max(1, Date().timeIntervalSince(item.ts)/60)
        let time = exp(-ageMin/360.0)
        return 1.0 * ctx.affinity(item)
             + 1.2 * ctx.engagementPred(item)
             + 1.0 * time
             + 0.8 * ctx.priceMomentum(item.collectionSlug)
             - 0.5 * ctx.diversityPenalty(item)
    }
}


