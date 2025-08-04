import SwiftUI

struct NFTCardView: View {
    var nft: NFT? = nil
    
    var body: some View {
        VStack {
            // NFT Image
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(12)
                
                if let nft = nft, let url = URL(string: nft.imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .cornerRadius(12)
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
            
            // NFT Info
            VStack(alignment: .leading, spacing: 4) {
                Text(nft?.name ?? "Untitled NFT")
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(nft?.priceString ?? "0.05 ETH")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "heart")
                        .foregroundColor(.red)
                    
                    Text("\(nft?.likes ?? 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NFTCardView()
}
