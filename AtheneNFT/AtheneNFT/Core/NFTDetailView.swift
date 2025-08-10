import SwiftUI

struct NFTDetailView: View {
    let nft: NFTDisplayCard
    @EnvironmentObject var auth: AuthenticationManager
    @StateObject private var social = SocialService.shared
    @State private var commentText: String = ""
    @State private var showShare = false

    private var socialKey: String { "nft:\(nft.id)" }

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
                            social.toggleLike(nftKey: socialKey, userId: userId)
                        }) {
                            Label("Like", systemImage: "heart")
                        }

                        if let url = URL(string: nft.imageUrl) {
                            Button(action: { showShare = true }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .sheet(isPresented: $showShare) {
                                ShareSheet(activityItems: [url])
                            }
                        }
                    }

                    Divider()

                    // Comments
                    Text("Comments")
                        .font(.system(size: geometry.scaled(20), weight: .semibold))

                    ForEach(social.commentsByNFT[socialKey] ?? []) { c in
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
                            social.addComment(nftKey: socialKey, userId: userId, text: commentText)
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

#Preview {
    NFTDetailView(nft: NFTDisplayCard(name: "Sample", imageUrl: "", priceString: "—", likes: 0))
        .environmentObject(AuthenticationManager.shared)
}

