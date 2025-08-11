import SwiftUI

struct NotificationsView: View {
    @StateObject private var stream = OpenSeaStreamService.shared

    var body: some View {
        NavigationView {
            List(stream.events) { e in
                HStack(spacing: 12) {
                    if let urlStr = e.imageURL, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: { Color.gray.opacity(0.2) }
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(e.title).font(.headline).lineLimit(1)
                        Text(e.subtitle).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let url = e.assetURL {
                        #if os(iOS)
                        UIApplication.shared.open(url)
                        #endif
                    }
                }
            }
            .navigationTitle("Live Stream")
        }
        .task {
            stream.connect() // or: stream.connect(collectionSlug: "doodles-official")
        }
        .onDisappear {
            stream.disconnect()
        }
    }
}

struct NotificationRow: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .padding(5)
            
            VStack(alignment: .leading) {
                Text("New bid on your NFT")
                    .font(.headline)
                
                Text("Someone bid 0.5 ETH on your NFT")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("12m ago")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    NotificationsView()
}
