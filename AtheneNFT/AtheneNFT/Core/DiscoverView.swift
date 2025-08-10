import SwiftUI
import Combine

// MARK: - Models

enum DiscoverCategory: String, CaseIterable, Identifiable, Codable {
    case all
    case art
    case gaming
    case photography
    case memberships
    case virtualWorlds

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .art: return "Art"
        case .gaming: return "Gaming"
        case .photography: return "Photography"
        case .memberships: return "Memberships"
        case .virtualWorlds: return "Virtual Worlds"
        }
    }

    // Map to your backend/OpenSea category keys if they differ
    var apiKey: String? { self == .all ? nil : rawValue }
}

struct Page<T: Decodable>: Decodable {
    let items: [T]
    let nextCursor: String?
}

struct NFTCollection: Identifiable, Decodable, Hashable {
    let id: String               // stable collection id (e.g., contract address or slug)
    let slug: String
    let name: String
    let imageURL: URL?
    let floorPriceETH: Double?
    let supply: Int?

    // Social actions (server-backed or local until synced)
    var isLiked: Bool
    var isFollowing: Bool
    var likeCount: Int
}

struct Comment: Identifiable, Decodable, Hashable {
    let id: String
    let author: String
    let body: String
    let createdAt: Date
}

// MARK: - Service Protocol

@MainActor
protocol DiscoverService {
    func fetchCollections(category: DiscoverCategory, chain: String, query: String?, cursor: String?) async throws -> Page<NFTCollection>
    func toggleLike(slug: String, like: Bool) async throws -> (isLiked: Bool, likeCount: Int)
    func toggleFollow(slug: String, follow: Bool) async throws -> Bool
    func postComment(slug: String, body: String) async throws -> Comment
    func fetchComments(slug: String) async throws -> [Comment]
}

// MARK: - API Service (wire your endpoint here)

final class APIBasedDiscoverService: DiscoverService {
    private let baseURL: URL
    private let session: URLSession
    private let authTokenProvider: () -> String? // Use your WC/Meta auth -> bearer

    init(baseURL: URL, authTokenProvider: @escaping () -> String?) {
        self.baseURL = baseURL
        self.authTokenProvider = authTokenProvider
        self.session = URLSession(configuration: .default)
    }

    private func makeRequest(path: String, query: [URLQueryItem] = [], method: String = "GET", body: Data? = nil) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { components.queryItems = query }
        var req = URLRequest(url: components.url!)
        req.httpMethod = method
        if let token = authTokenProvider() {
            req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            req.httpBody = body
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return req
    }

    func fetchCollections(category: DiscoverCategory, chain: String, query: String?, cursor: String?) async throws -> Page<NFTCollection> {
        // Adjust path/params to your real endpoint. Example assumes:
        // GET /v1/collections?chain=ethereum&category=art&cursor=...&q=...
        var items: [URLQueryItem] = [URLQueryItem(name: "chain", value: chain)]
        if let key = category.apiKey { items.append(URLQueryItem(name: "category", value: key)) }
        if let q = query, !q.isEmpty { items.append(URLQueryItem(name: "q", value: q)) }
        if let cursor = cursor { items.append(URLQueryItem(name: "cursor", value: cursor)) }

        let req = try makeRequest(path: "/v1/collections", query: items)
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Page<NFTCollection>.self, from: data)
    }

    func toggleLike(slug: String, like: Bool) async throws -> (isLiked: Bool, likeCount: Int) {
        // POST /v1/collections/{slug}/like { like: Bool }
        let payload = try JSONEncoder().encode(["like": like])
        let req = try makeRequest(path: "/v1/collections/\(slug)/like", method: "POST", body: payload)
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        struct LikeResponse: Decodable { let isLiked: Bool; let likeCount: Int }
        let decoded = try JSONDecoder().decode(LikeResponse.self, from: data)
        return (decoded.isLiked, decoded.likeCount)
    }

    func toggleFollow(slug: String, follow: Bool) async throws -> Bool {
        // POST /v1/collections/{slug}/follow { follow: Bool }
        let payload = try JSONEncoder().encode(["follow": follow])
        let req = try makeRequest(path: "/v1/collections/\(slug)/follow", method: "POST", body: payload)
        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return follow
    }

    func postComment(slug: String, body: String) async throws -> Comment {
        // POST /v1/collections/{slug}/comments { body: String }
        struct Payload: Encodable { let body: String }
        let req = try makeRequest(path: "/v1/collections/\(slug)/comments", method: "POST", body: try JSONEncoder().encode(Payload(body: body)))
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(Comment.self, from: data)
    }

    func fetchComments(slug: String) async throws -> [Comment] {
        // GET /v1/collections/{slug}/comments
        let req = try makeRequest(path: "/v1/collections/\(slug)/comments")
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode([Comment].self, from: data)
    }
}

// MARK: - Mock Service (for previews / offline)

final class MockDiscoverService: DiscoverService {
    func fetchCollections(category: DiscoverCategory, chain: String, query: String?, cursor: String?) async throws -> Page<NFTCollection> {
        let seed = (0..<12).map { i in
            NFTCollection(
                id: "c_\(category.rawValue)_\(i)",
                slug: "slug-\(i)",
                name: "\(category.title) \(i)",
                imageURL: URL(string: "https://picsum.photos/seed/\(category.rawValue)_\(i)/400"),
                floorPriceETH: i % 3 == 0 ? Double.random(in: 0.02...1.9) : nil,
                supply: Int.random(in: 100...10000),
                isLiked: Bool.random(),
                isFollowing: Bool.random(),
                likeCount: Int.random(in: 0...999)
            )
        }
        return Page(items: seed, nextCursor: nil)
    }

    func toggleLike(slug: String, like: Bool) async throws -> (isLiked: Bool, likeCount: Int) {
        (like, Int.random(in: 0...999))
    }

    func toggleFollow(slug: String, follow: Bool) async throws -> Bool { follow }

    func postComment(slug: String, body: String) async throws -> Comment {
        Comment(id: UUID().uuidString, author: "You", body: body, createdAt: Date())
    }

    func fetchComments(slug: String) async throws -> [Comment] {
        [Comment(id: "1", author: "alice.eth", body: "Love this collection!", createdAt: Date().addingTimeInterval(-7200))]
    }
}

// MARK: - ViewModel

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var category: DiscoverCategory = .all
    @Published var gridItems: [NFTCollection] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var searchText: String = ""
    @Published var nextCursor: String? = nil

    private let service: DiscoverService
    private let chain = "ethereum" // ETH only as requested

    init(service: DiscoverService) { self.service = service }

    func refresh() async {
        await load(reset: true)
    }

    func loadMoreIfNeeded(current item: NFTCollection?) async {
        guard let item = item else { return }
        let thresholdIndex = gridItems.index(gridItems.endIndex, offsetBy: -4, limitedBy: gridItems.startIndex) ?? gridItems.startIndex
        if gridItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex, nextCursor != nil, !isLoading {
            await load(reset: false)
        }
    }

    func load(reset: Bool) async {
        if isLoading { return }
        isLoading = true
        error = nil
        do {
            let cursor = reset ? nil : nextCursor
            let page = try await service.fetchCollections(category: category, chain: chain, query: searchText.isEmpty ? nil : searchText, cursor: cursor)
            if reset { gridItems = page.items } else { gridItems.append(contentsOf: page.items) }
            nextCursor = page.nextCursor
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func toggleLike(_ collection: NFTCollection) async {
        guard let idx = gridItems.firstIndex(of: collection) else { return }
        var updating = gridItems[idx]
        let newState = !updating.isLiked
        updating.isLiked = newState
        updating.likeCount += newState ? 1 : max(0, updating.likeCount - 1) - updating.likeCount
        gridItems[idx] = updating
        do {
            let result = try await service.toggleLike(slug: updating.slug, like: newState)
            updating.isLiked = result.isLiked
            updating.likeCount = result.likeCount
            gridItems[idx] = updating
        } catch {
            // revert on failure
            updating.isLiked.toggle()
            gridItems[idx] = updating
        }
    }

    func toggleFollow(_ collection: NFTCollection) async {
        guard let idx = gridItems.firstIndex(of: collection) else { return }
        var updating = gridItems[idx]
        let newState = !updating.isFollowing
        updating.isFollowing = newState
        gridItems[idx] = updating
        do {
            _ = try await service.toggleFollow(slug: updating.slug, follow: newState)
        } catch {
            updating.isFollowing.toggle()
            gridItems[idx] = updating
        }
    }
}

// MARK: - Views

struct DiscoverView: View {
    @StateObject private var vm: DiscoverViewModel

    init(service: DiscoverService? = nil) {
        // Swap the service here: APIBasedDiscoverService or MockDiscoverService
        let svc = service ?? MockDiscoverService()
        _vm = StateObject(wrappedValue: DiscoverViewModel(service: svc))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategoryPicker(category: $vm.category) {
                    Task { await vm.refresh() }
                }
                content
            }
            .navigationTitle("Discover")
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .onSubmit(of: .search) { Task { await vm.refresh() } }
            .task { await vm.refresh() }
        }
    }

    private var content: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 164), spacing: 14)], spacing: 14) {
                ForEach(vm.gridItems, id: \ .id) { item in
                    DiscoverCard(item: item,
                                 likeAction: { Task { await vm.toggleLike(item) } },
                                 followAction: { Task { await vm.toggleFollow(item) } })
                        .onAppear { Task { await vm.loadMoreIfNeeded(current: item) } }
                }
            }
            .padding(16)

            if vm.isLoading {
                ProgressView().padding()
            }
        }
        .refreshable { await vm.refresh() }
        .overlay(alignment: .center) {
            if !vm.isLoading && vm.gridItems.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles.rectangle.stack").font(.system(size: 36))
                    Text("No collections yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 48)
            }
        }
    }
}

struct CategoryPicker: View {
    @Binding var category: DiscoverCategory
    var onChange: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(DiscoverCategory.allCases) { cat in
                    let selected = category == cat
                    Button(action: { category = cat; onChange() }) {
                        Text(cat.title)
                            .font(.subheadline.weight(.semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(selected ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.12))
                            .foregroundStyle(selected ? .accentColor : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct DiscoverCard: View {
    let item: NFTCollection
    let likeAction: () -> Void
    let followAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Rectangle().fill(Color.gray.opacity(0.06)).aspectRatio(1, contentMode: .fit)
                    .overlay {
                        if let url = item.imageURL {
                            AsyncImage(url: url) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image(systemName: "photo").font(.system(size: 28)).foregroundStyle(.secondary)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                HStack(spacing: 8) {
                    Button(action: followAction) {
                        Label(item.isFollowing ? "Following" : "Follow", systemImage: item.isFollowing ? "checkmark" : "plus")
                            .labelStyle(.titleAndIcon)
                            .font(.caption.bold())
                            .padding(.vertical, 6).padding(.horizontal, 10)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                .padding(8)
            }

            Text(item.name)
                .font(.headline)
                .lineLimit(1)

            HStack {
                if let fp = item.floorPriceETH {
                    Text(String(format: "%.3f ETH", fp)).font(.subheadline).foregroundStyle(.secondary)
                } else {
                    Text("— ETH").font(.subheadline).foregroundStyle(.tertiary)
                }
                Spacer()
                Button(action: likeAction) {
                    HStack(spacing: 4) {
                        Image(systemName: item.isLiked ? "heart.fill" : "heart")
                        Text("\(item.likeCount)")
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}

// MARK: - Collection Detail + Comments (Optional)

struct CollectionDetailView: View {
    let item: NFTCollection
    @State private var comments: [Comment] = []
    @State private var newComment: String = ""
    @Environment(\.dismiss) private var dismiss

    let service: DiscoverService

    var body: some View {
        List {
            Section {
                HStack(alignment: .top) {
                    AsyncImage(url: item.imageURL) { $0.resizable().scaledToFit() } placeholder: { Color.gray.opacity(0.1) }
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name).font(.title3.bold())
                        if let fp = item.floorPriceETH { Text("Floor: \(String(format: "%.3f", fp)) ETH").foregroundStyle(.secondary) }
                        if let s = item.supply { Text("Supply: \(s)").foregroundStyle(.secondary) }
                    }
                    Spacer()
                }
            }

            Section("Comments") {
                ForEach(comments) { c in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(c.author).font(.caption.bold()).foregroundStyle(.secondary)
                        Text(c.body)
                        Text(c.createdAt.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }

                HStack {
                    TextField("Add a comment…", text: $newComment)
                    Button("Post") { Task { await post() } }.disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationTitle(item.name)
        .task { await load() }
    }

    private func load() async { comments = (try? await service.fetchComments(slug: item.slug)) ?? [] }
    private func post() async {
        guard !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if let c = try? await service.postComment(slug: item.slug, body: newComment) {
            comments.insert(c, at: 0)
            newComment = ""
        }
    }
}

// MARK: - Preview

struct Discover_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView(service: MockDiscoverService())
    }
}
