import SwiftUI

// Use a simpler approach - define the extension directly in this file
extension GeometryProxy {
    func scaled(_ value: CGFloat) -> CGFloat {
        return value * min(self.size.width / 390, 1.3)
    }
}

struct DiscoverView: View {
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: geometry.scaled(160)))
                        ],
                        spacing: geometry.scaled(20)
                    ) {
                        ForEach(0..<10) { _ in
                            // Use a simple card instead of NFTCardView
                            DiscoverCardView(geometry: geometry)
                                .frame(height: geometry.scaled(240))
                        }
                    }
                    .padding(geometry.scaled(16))
                }
                .navigationTitle("Discover")
                .searchable(text: .constant(""))
            }
        }
    }
}

// Simple card for compilation
struct DiscoverCardView: View {
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(geometry.scaled(12))
            
            VStack(alignment: .leading, spacing: geometry.scaled(4)) {
                Text("NFT Title")
                    .font(.system(size: geometry.scaled(16), weight: .semibold))
                    .lineLimit(1)
                
                HStack {
                    Text("0.05 ETH")
                        .font(.system(size: geometry.scaled(14)))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "heart")
                        .font(.system(size: geometry.scaled(14)))
                        .foregroundColor(.red)
                    
                    Text("42")
                        .font(.system(size: geometry.scaled(12)))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, geometry.scaled(8))
            .padding(.vertical, geometry.scaled(6))
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(geometry.scaled(12))
    }
}

#Preview {
    DiscoverView()
}
