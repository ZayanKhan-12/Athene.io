import SwiftUI

// Import the shared models
import Foundation

// Extension for geometry scaling
extension GeometryProxy {
    func scaled(_ value: CGFloat) -> CGFloat {
        return value * min(self.size.width / 390, 1.3)
    }
}

// Simple NFT model for the card view
struct NFTDisplayCard: Identifiable {
    var id = UUID()
    var name = "Untitled NFT"
    var imageUrl = ""
    var priceString = "0.05 ETH"
    var likes = 0
}

struct NFTCardView: View {
    var nft: NFTDisplayCard? = nil
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // NFT Image
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(geometry.scaled(12))
                    
                    if let nft = nft, let url = URL(string: nft.imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .cornerRadius(geometry.scaled(12))
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: geometry.scaled(30)))
                            .foregroundColor(.gray)
                    }
                }
                
                // NFT Info
                VStack(alignment: .leading, spacing: geometry.scaled(4)) {
                    Text(nft?.name ?? "Untitled NFT")
                        .font(.system(size: geometry.scaled(16), weight: .semibold))
                        .lineLimit(1)
                    
                    HStack {
                        Text(nft?.priceString ?? "0.05 ETH")
                            .font(.system(size: geometry.scaled(14)))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "heart")
                            .font(.system(size: geometry.scaled(14)))
                            .foregroundColor(.red)
                        
                        Text("\(nft?.likes ?? 0)")
                            .font(.system(size: geometry.scaled(12)))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, geometry.scaled(8))
                .padding(.vertical, geometry.scaled(6))
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(geometry.scaled(12))
            .shadow(color: Color.black.opacity(0.1), 
                    radius: geometry.scaled(5), 
                    x: 0, 
                    y: geometry.scaled(2))
        }
    }
}

#Preview {
    NFTCardView()
        .frame(width: 180, height: 240)
        .padding()
}
