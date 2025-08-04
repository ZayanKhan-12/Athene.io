import SwiftUI

// Use a simpler approach - define the extension directly in this file
extension GeometryProxy {
    func scaled(_ value: CGFloat) -> CGFloat {
        return value * min(self.size.width / 390, 1.3)
    }
}

@available(iOS 14.0, macOS 11.0, *)
struct HomeView: View {
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Featured NFTs")
                            .font(.system(size: geometry.scaled(24), weight: .bold))
                            .padding(geometry.scaled(16))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: geometry.scaled(15)) {
                                ForEach(0..<5) { _ in
                                    SimplifiedNFTCard(geometry: geometry)
                                }
                            }
                            .padding(.horizontal, geometry.scaled(16))
                        }
                        
                        Text("Recent Activity")
                            .font(.system(size: geometry.scaled(24), weight: .bold))
                            .padding(geometry.scaled(16))
                        
                        ForEach(0..<3) { _ in
                            ActivityRow(geometry: geometry)
                        }
                    }
                }
                #if os(iOS)
                .navigationBarTitle("Home")
                #endif
            }
        }
    }
}

struct SimplifiedNFTCard: View {
    var geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(
                    width: geometry.scaled(150), 
                    height: geometry.scaled(150)
                )
                .cornerRadius(geometry.scaled(10))
            
            Text("NFT Title")
                .font(.system(size: geometry.scaled(17), weight: .semibold))
            
            Text("0.05 ETH")
                .font(.system(size: geometry.scaled(15)))
                .foregroundColor(.secondary)
        }
    }
}

struct ActivityRow: View {
    var geometry: GeometryProxy
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(
                    width: geometry.scaled(50), 
                    height: geometry.scaled(50)
                )
            
            VStack(alignment: .leading) {
                Text("Activity Title")
                    .font(.system(size: geometry.scaled(17), weight: .semibold))
                
                Text("Some details about this activity")
                    .font(.system(size: geometry.scaled(15)))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("2h ago")
                .font(.system(size: geometry.scaled(12)))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, geometry.scaled(16))
        .padding(.vertical, geometry.scaled(5))
    }
}

#if canImport(SwiftUI)
@available(iOS 14.0, macOS 11.0, *)
#Preview {
    HomeView()
}
#endif
