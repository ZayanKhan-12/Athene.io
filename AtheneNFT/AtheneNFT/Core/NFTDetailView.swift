import SwiftUI

struct NFTDetailView: View {
    let nft: NFTDisplayCard
    @EnvironmentObject var auth: AuthenticationManager
    @StateObject private var social = SocialService.shared
    @State private var commentText: String = ""
    @State private var showShare = false
    @State private var isConnectingWC = false
    @State private var isListing = false
    @State private var listingPrice: String = ""

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: geometry.scaled(16)) {
                    // Image
                    if let url = URL(string: nft.imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: { ProgressView() }
                        .cornerRadius(geometry.scaled(12))
                    }

                    // Title and price
                    VStack(alignment: .leading, spacing: geometry.scaled(8)) {
                        Text(nft.name)
                            .font(.system(size: geometry.scaled(24), weight: .bold))
                        Text(nft.priceString)
                            .font(.system(size: geometry.scaled(18)))
                            .foregroundColor(.secondary)
                    }

                    // Actions row
                    HStack(spacing: geometry.scaled(16)) {
                        Button(action: {
                            guard let userId = auth.currentUser?.id else { return }
                            let key = "\(nft.contractAddress):\(nft.tokenId)"
                            social.toggleLike(nftKey: key, userId: userId)
                        }) {
                            Label("Like", systemImage: "heart")
                        }

                        if let url = nft.openseaURL {
                            Link(destination: url) {
                                Label("View on OpenSea", systemImage: "safari")
                            }
                            // Simple deeplink hints for buy/list by opening OpenSea asset page
                            Link("Buy", destination: url)
                            Button("List") { isListing = true }
                            Button(action: { showShare = true }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .sheet(isPresented: $showShare) {
                                ShareSheet(activityItems: [url])
                            }
                        }
                    }

                    // Listing sheet
                    .sheet(isPresented: $isListing) {
                        VStack(spacing: 16) {
                            Text("List for Sale").font(.headline)
                            TextField("Price (ETH)", text: $listingPrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                            Button(action: {
                                Task {
                                    await startListing()
                                }
                            }) {
                                Text(isConnectingWC ? "Connecting…" : "Create Listing")
                                    .padding()
                            }
                            Button("Cancel") { isListing = false }
                        }
                        .padding()
                    }

                    Divider()

                    // Comments
                    Text("Comments")
                        .font(.system(size: geometry.scaled(20), weight: .semibold))

                    let key = "\(nft.contractAddress):\(nft.tokenId)"
                    ForEach(social.commentsByNFT[key] ?? []) { c in
                        VStack(alignment: .leading, spacing: geometry.scaled(4)) {
                            Text(c.text)
                            Text(c.timestamp, style: .relative)
                                .font(.system(size: geometry.scaled(12)))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, geometry.scaled(4))
                    }

                    HStack {
                        TextField("Add a comment", text: $commentText)
                            .textFieldStyle(.roundedBorder)
                        Button("Send") {
                            guard let userId = auth.currentUser?.id, !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            social.addComment(nftKey: key, userId: userId, text: commentText)
                            commentText = ""
                        }
                    }
                }
                .padding(geometry.scaled(16))
            }
            .navigationTitle("NFT Detail")
        }
    }
}

extension NFTDetailView {
    private func startListing() async {
        guard !listingPrice.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isConnectingWC = true
        defer { isConnectingWC = false }
        do {
            let (maker, _) = try await WalletConnectService.shared.connect()
            let create = ListingBackendClient.CreateBody(
              chain: nft.chain.rawValue,
              contract: nft.contractAddress,
              tokenId: nft.tokenId,
              price: listingPrice,
              maker: maker
            )
            let resp = try await ListingBackendClient.create(create)
            // Ask user to sign typed data via WC (placeholder or guarded implementation)
            let typed = resp.typedData.mapValues { any -> Any in
              switch any {
                case .string(let s): return s
                case .number(let d): return d
                case .bool(let b): return b
                case .array(let a): return a.map { $0 }
                case .object(let o): return o.mapValues { $0 }
                case .null: return NSNull()
              }
            }
            let signature = try await WalletConnectService.shared.signTypedData(address: maker, typedData: typed)
            let submit = ListingBackendClient.SubmitBody(requestId: resp.requestId, signature: signature)
            _ = try await ListingBackendClient.submit(submit)
            isListing = false
        } catch {
            // Present a simple alert via print for now
            print("Listing failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NFTDetailView(nft: NFTDisplayCard(name: "Sample", imageUrl: "", priceString: "—", likes: 0, contractAddress: "0x", tokenId: "1", chain: .ethereum))
        .environmentObject(AuthenticationManager.shared)
}


