import Foundation

struct OpenSeaAPI {
    let base = URL(string: "https://api.opensea.io")!
    let apiKey: String

    private func request(_ path: String, query: [URLQueryItem] = []) -> URLRequest {
        var comp = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { comp.queryItems = query }
        var req = URLRequest(url: comp.url!)
        req.setValue("4ec329fc4a3141d7bb2c6a1e1875b7ef", forHTTPHeaderField: "x-api-key")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }

    func getCollection(slug: String) async throws -> Data {
        try await fetch(request("/api/v2/collections/\(slug)"))
    }

    func getListings(chain: String, protocolName: String, query: [URLQueryItem]) async throws -> Data {
        try await fetch(request("/api/v2/orders/\(chain)/\(protocolName)/listings", query: query))
    }

    func getOffers(chain: String, protocolName: String, query: [URLQueryItem]) async throws -> Data {
        try await fetch(request("/api/v2/orders/\(chain)/\(protocolName)/offers", query: query))
    }

    func getEvents(query: [URLQueryItem]) async throws -> Data {
        try await fetch(request("/api/v2/events", query: query))
    }

    private func fetch(_ req: URLRequest, retries: Int = 2) async throws -> Data {
        var attempt = 0
        var lastErr: Error?
        while attempt <= retries {
            do {
                let (data, resp) = try await URLSession.shared.data(for: req)
                if let http = resp as? HTTPURLResponse {
                    if (200..<300).contains(http.statusCode) { return data }
                    if http.statusCode == 429 {
                        let delay = http.value(forHTTPHeaderField: "Retry-After").flatMap(Double.init) ?? (0.5 * pow(2.0, Double(attempt)))
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    } else {
                        throw URLError(.badServerResponse)
                    }
                }
            } catch {
                lastErr = error
                attempt += 1
                let jitter = Double.random(in: 0...0.2)
                let backoff = (0.35 + jitter) * pow(1.8, Double(attempt))
                try? await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
            }
        }
        throw lastErr ?? URLError(.unknown)
    }
}


