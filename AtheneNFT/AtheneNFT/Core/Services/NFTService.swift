import Foundation
import Combine

@MainActor
final class NFTService: ObservableObject {
    static let shared = NFTService()

    struct NFTMedia: Hashable {
        let imageURL: URL?
        let animationURL: URL?
    }

    private init() {}

    // Placeholder async API so callers can compile even before real backend wiring
    func fetchMedia(contract: String, tokenId: String) async -> NFTMedia? {
        return nil
    }
}

