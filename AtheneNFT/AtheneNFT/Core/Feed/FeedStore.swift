import Foundation
import SwiftUI

@MainActor
final class FeedStore: ObservableObject {
    @Published private(set) var items: [FeedItem] = []
    private var scores: [FeedItem: Double] = [:]
    private var seen = OrderedSet<String>()
    private let capacity: Int
    private let maxSeen: Int = 5000
    private let diversityWindow = 20
    private let maxPerCollectionInTop = 2

    init(capacity: Int = 300) {
        self.capacity = capacity
    }

    func upsert(_ item: FeedItem, score: Double) {
        let key = item.id
        if seen.contains(key) == false {
            seen.insert(key)
            if seen.count > maxSeen { seen.removeFirst(seen.count - maxSeen) }
        }
        scores[item] = score
        var set = Set(items)
        if !set.contains(item) { items.append(item) }
        items.sort { (scores[$0] ?? .leastNonzeroMagnitude) > (scores[$1] ?? .leastNonzeroMagnitude) }
        if items.count > capacity { items.removeLast(items.count - capacity) }
        applyDiversityGuard()
    }

    private func applyDiversityGuard() {
        var counts: [String:Int] = [:]
        var pruned: [FeedItem] = []
        for (idx, it) in items.enumerated() {
            let slug = it.collectionSlug
            let c = (counts[slug] ?? 0)
            if idx < diversityWindow && c >= maxPerCollectionInTop { continue }
            counts[slug] = c + 1
            pruned.append(it)
        }
        items = pruned
    }
}

// Minimal ordered set for small LRU
fileprivate struct OrderedSet<Element: Hashable> {
    private var array: [Element] = []
    private var set: Set<Element> = []
    var count: Int { array.count }
    mutating func insert(_ e: Element) { if set.insert(e).inserted { array.append(e) } }
    mutating func removeFirst(_ n: Int) { guard n > 0 && n <= array.count else { return }
        let removed = array.prefix(n)
        removed.forEach { set.remove($0) }
        array.removeFirst(n)
    }
    func contains(_ e: Element) -> Bool { set.contains(e) }
}


